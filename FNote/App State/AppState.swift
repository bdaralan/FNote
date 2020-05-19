//
//  AppState.swift
//  FNote
//
//  Created by Dara Beng on 1/22/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation
import CoreData
import Combine


class AppState: ObservableObject {
    
    // MARK: Property
    
    /// The parent context used to read objects.
    private(set) var parentContext: NSManagedObjectContext
    
    private(set) lazy var preference = getPreference()
    
    var currentNoteCards: [NoteCard] {
        currentNoteCardsFetchController.fetchedObjects ?? []
    }
    
    var collections: [NoteCardCollection] {
        collectionFetchController.fetchedObjects ?? []
    }
    
    var tags: [Tag] {
        tagFetchController.fetchedObjects ?? []
    }
    
    var iCloudActive: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }
    
    private(set) lazy var currentCollection = collections.first(where: { $0.uuid == AppCache.currentCollectionUUID })
    
    private var isImportingData = false
    private var isLowercasingTags = false
    
    
    // MARK: Fetch Controller
    
    private lazy var currentNoteCardsFetchController: NSFetchedResultsController<NoteCard> = {
        let controller = NSFetchedResultsController<NoteCard>(
            fetchRequest: NoteCard.requestNoteCards(collectionUUID: currentCollection?.uuid ?? ""),
            managedObjectContext: parentContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try? controller.performFetch()
        return controller
    }()
    
    private lazy var collectionFetchController: NSFetchedResultsController<NoteCardCollection> = {
        let controller = NSFetchedResultsController<NoteCardCollection>(
            fetchRequest: NoteCardCollection.requestAllCollections(),
            managedObjectContext: parentContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try? controller.performFetch()
        return controller
    }()
    
    private lazy var tagFetchController: NSFetchedResultsController<Tag> = {
        let controller = NSFetchedResultsController<Tag>(
            fetchRequest: Tag.requestAllTags(),
            managedObjectContext: parentContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try? controller.performFetch()
        return controller
    }()
    
    
    // MARK: Constructor
    
    init(parentContext: NSManagedObjectContext) {
        self.parentContext = parentContext
    }
}


// MARK: - Current Collection

extension AppState {
    
    /// Set the current collection.
    ///
    /// The method also updates the `currentNoteCards`.
    ///
    /// - Parameter collection: The collection to assign or `nil` for none.
    func setCurrentCollection(_ collection: NoteCardCollection?) {
        AppCache.currentCollectionUUID = collection?.uuid
        currentCollection = collection
        fetchCurrentNoteCards()
    }
    
    func fetchCurrentNoteCards() {
        let request: NSFetchRequest<NoteCard>
        
        if let collection = currentCollection {
            let uuid = collection.uuid
            let sortBy = preference.noteCardSortOption
            let ascending = preference.noteCardSortOptionAscending
            request = NoteCard.requestNoteCards(collectionUUID: uuid, sortBy: sortBy, ascending: ascending)
        } else {
            request = NoteCard.requestNone()
        }
        
        currentNoteCardsFetchController.fetchRequest.predicate = request.predicate
        currentNoteCardsFetchController.fetchRequest.sortDescriptors = request.sortDescriptors
        try? currentNoteCardsFetchController.performFetch()
    }
    
    func fetchCollections() {
        try? collectionFetchController.performFetch()
    }
    
    func fetchTags() {
        try? tagFetchController.performFetch()
    }
    
    func fetchV1Collections() -> [NoteCardCollection] {
        let request = NoteCardCollection.requestV1NoteCardCollections()
        let results = try? parentContext.fetch(request)
        return results ?? []
    }
}


// MARK: - Modifier & Import

extension AppState {
    
    func deleteUnusedTags(in context: NSManagedObjectContext) -> Bool {
        guard let results = try? context.fetch(Tag.requestUnusedTags()) else { return false }
        guard results.isEmpty == false else { return false }
        results.forEach(context.delete)
        return true
    }
    
    func lowercaseAllTagsIfAny() {
        guard isLowercasingTags == false else { return }
        isLowercasingTags = true
        
        DispatchQueue.global(qos: .default).async {
            let renameContext = self.parentContext.newChildContext(type: .privateQueueConcurrencyType)
            let request = Tag.requestAllTags()
            let results = try? renameContext.fetch(request)
            let tags = results?.filter({ $0.name.filter(\.isUppercase).isEmpty == false }) ?? []
            
            guard tags.isEmpty == false else {
                self.isLowercasingTags = false
                return
            }
            
            for tag in tags {
                let tag = tag.get(from: renameContext)
                var modifier = ObjectModifier<Tag>(.update(tag), useSeparateContext: false)
                modifier.name = tag.name
            }
            
            renameContext.perform {
                renameContext.quickSave()
                renameContext.parent?.perform {
                    renameContext.parent?.quickSave()
                    self.isLowercasingTags = false
                }
            }
        }
    }
    
    func importArchivedCollectionIfAny() {
        guard isImportingData == false else { return }
        isImportingData = true
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let self = self else { return }
            let importContext = self.parentContext.newChildContext(type: .privateQueueConcurrencyType)
            let request = NoteCardCollection.requestV1NoteCardCollections()
            
            guard let collections = try? importContext.fetch(request) else {
                self.isImportingData = false
                return
            }
            
            guard collections.isEmpty == false else {
                self.isImportingData = false
                return
            }
            
            ObjectMaker.importV1Collections(collections, using: importContext, prefix: "[V1] ")
            
            for collection in collections {
                let collection = collection.get(from: importContext)
                importContext.delete(collection)
            }
            
            importContext.perform {
                do {
                    try importContext.save()
                    self.parentContext.perform {
                        self.parentContext.quickSave()
                        self.isImportingData = false
                    }
                } catch {
                    self.isImportingData = false
                    print("⚠️ import data failed with error: \(error). ⚠️")
                    print("⚠️ ignore the import and wait for future fix ⚠️")
                }
            }
        }
    }
}


extension AppState {
    
    func isDuplicateTagName(_ name: String) -> Bool {
        let nameField = #keyPath(Tag.name)
        let metadataField = #keyPath(Tag.metadata)
        let predicate = NSPredicate(format: "\(nameField) =[c] %@ AND \(metadataField) != nil", name)
        let request = Tag.fetchRequest() as NSFetchRequest<Tag>
        request.predicate = predicate
        request.sortDescriptors = []
        let results = (try? parentContext.fetch(request)) ?? []
        return results.isEmpty == false
    }
    
    func isDuplicateCollectionName(_ name: String) -> Bool {
        let nameField = #keyPath(NoteCardCollection.name)
        let metadataField = #keyPath(NoteCardCollection.metadata)
        let predicate = NSPredicate(format: "\(nameField) =[c] %@ AND \(metadataField) != nil", name)
        let request = NoteCardCollection.fetchRequest() as NSFetchRequest<NoteCardCollection>
        request.predicate = predicate
        request.sortDescriptors = []
        let results = (try? parentContext.fetch(request)) ?? []
        return results.isEmpty == false
    }
}









