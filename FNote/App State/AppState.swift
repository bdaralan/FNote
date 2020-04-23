//
//  AppState.swift
//  FNote
//
//  Created by Dara Beng on 1/22/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation
import CoreData


class AppState: ObservableObject {
    
    // MARK: Property
    
    /// The parent context used to read objects.
    private(set) var parentContext: NSManagedObjectContext
    
    /// The context used to create, update, and delete objects.
    private(set) var cudContext: NSManagedObjectContext?
    
    let currentNoteCardsWillChange = ObjectWillChangePublisher()
    
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
    
    @Published private(set) var currentCollectionID: String? = AppCache.currentCollectionUUID
    private(set) lazy var currentCollection = collections.first(where: { $0.uuid == currentCollectionID })
    
    var noteCardSortOption: NoteCardSortField = .translation
    var noteCardSortOptionAscending = true
    
    @Published var showDidCopyFileAlert = false
    var copiedFileName = ""
    
    
    // MARK: Fetch Controller
    
    private lazy var currentNoteCardsFetchController: NSFetchedResultsController<NoteCard> = {
        let controller = NSFetchedResultsController<NoteCard>(
            fetchRequest: NoteCard.requestNoteCards(collectionUUID: currentCollectionID ?? ""),
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
        currentCollectionID = collection?.uuid
        currentCollection = collection
        fetchCurrentNoteCards()
    }
    
    func fetchCurrentNoteCards() {
        let newRequest: NSFetchRequest<NoteCard>
        
        if let collection = currentCollection {
            newRequest = NoteCard.requestNoteCards(
                collectionUUID: collection.uuid,
                sortBy: noteCardSortOption,
                ascending: noteCardSortOptionAscending
            )
        } else {
            newRequest = NoteCard.requestNone()
        }
        
        let currentRequest = currentNoteCardsFetchController.fetchRequest
        currentRequest.predicate = newRequest.predicate
        currentRequest.sortDescriptors = newRequest.sortDescriptors
        
        DispatchQueue.main.async {
            self.currentNoteCardsWillChange.send()
        }
        try? currentNoteCardsFetchController.performFetch()
    }
    
    func fetchCollections() {
        try? collectionFetchController.performFetch()
    }
    
    func fetchTags() {
        try? tagFetchController.performFetch()
    }
}


// MARK: - Create & Update Object

extension AppState {
    
    func createNoteCard(with request: NoteCardCUDRequest) -> ObjectCUDResult<NoteCard> {
        let context = parentContext.newChildContext()
        let noteCard = NoteCard(context: context)
        
        request.changeContext(context)
        request.update(noteCard)
        
        if noteCard.isValid() {
            return .created(noteCard, context)
        }
        
        return .failed
    }
    
    func updateNoteCard(_ noteCard: NoteCard, with request: NoteCardCUDRequest) -> ObjectCUDResult<NoteCard> {
        let context = parentContext.newChildContext()
        let noteCardToUpdate = noteCard.get(from: context)
        
        request.changeContext(context)
        request.update(noteCardToUpdate)
            
        if noteCardToUpdate.isValid() {
            return .updated(noteCardToUpdate, context)
        }
            
        return .failed
    }
    
    func createNoteCardCollection(with request: NoteCardCollectionCUDRequest) -> ObjectCUDResult<NoteCardCollection> {
        let context = parentContext.newChildContext()
        let collection = NoteCardCollection(context: context)
        
        request.changeContext(context)
        request.update(collection)
        
        if collection.isValid() {
            let names = collections.map({ $0.name })
            if Self.isNameUnique(collection.name, existingNames: names) {
                return .created(collection, context)
            }
        }
        
        return .failed
    }
    
    func updateNoteCardCollection(_ collection: NoteCardCollection, with request: NoteCardCollectionCUDRequest) -> ObjectCUDResult<NoteCardCollection> {
        let context = parentContext.newChildContext()
        let collectionToUpdate = collection.get(from: context)
        
        request.changeContext(context)
        request.update(collectionToUpdate)
        
        if collectionToUpdate.isValid() {
            let currentName = collection.name
            let updatedName = collectionToUpdate.name
            
            if currentName.lowercased() == updatedName.lowercased() {
                if currentName == updatedName {
                    return .unchanged
                } else {
                    return .updated(collectionToUpdate, context)
                }
            }
            
            let names = collections.map({ $0.name })
            if Self.isNameUnique(collectionToUpdate.name, existingNames: names) {
                return .updated(collectionToUpdate, context)
            }
        }
        
        return .failed
    }
    
    func createTag(with request: TagCUDRequest) -> ObjectCUDResult<Tag> {
        let context = parentContext.newChildContext()
        let tag = Tag(context: context)
        
        request.changeContext(context)
        request.update(tag)
        
        if tag.isValid() {
            let names = tags.map({ $0.name })
            if Self.isNameUnique(tag.name, existingNames: names) {
                return .created(tag, context)
            }
        }
        
        return .failed
    }
    
    func updateTag(_ tag: Tag, with request: TagCUDRequest) -> ObjectCUDResult<Tag> {
        let context = parentContext.newChildContext()
        let tagToUpdate = tag.get(from: context)
        
        request.changeContext(context)
        request.update(tagToUpdate)
        
        if tag.isValid() {
            let currentName = tag.name
            let updatedName = tagToUpdate.name
            
            if currentName.lowercased() == updatedName.lowercased() {
                if currentName == updatedName {
                    return .unchanged
                } else {
                    return .updated(tagToUpdate, context)
                }
            }
            
            let names = tags.map({ $0.name })
            if Self.isNameUnique(updatedName, existingNames: names) {
                return .updated(tagToUpdate, context)
            }
        }
        
        return .failed
    }
}


// MARK: - Delete Object

extension AppState {
        
    func deleteObject<T>(_ object: T) -> ObjectCUDResult<T> where T: NSManagedObject {
        let context = parentContext.newChildContext()
        let objectToDelete = object.get(from: context)
        context.delete(objectToDelete)
        return .deleted(context)
    }
    
    func deleteUnusedTags() -> ObjectCUDResult<Tag> {
        let tagsToDelete = tags.filter({ $0.noteCards.isEmpty })
        
        if tagsToDelete.isEmpty {
            let result = ObjectCUDResult<Tag>.unchanged
            return result
        }
        
        let context = parentContext.newChildContext()
        for tag in tagsToDelete {
            let tagInContext = tag.get(from: context)
            context.delete(tagInContext)
        }
        
        let result = ObjectCUDResult<Tag>.deleted(context)
        return result
    }
}


extension AppState {
    
    static func isNameUnique(_ name: String, existingNames: [String]) -> Bool {
        let names = existingNames.map({ $0.lowercased() })
        let name = name.trimmed().lowercased()
        return !names.contains(name)
    }
}









