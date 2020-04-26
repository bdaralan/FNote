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


// MARK: - Delete Object

extension AppState {
    
    func deleteUnusedTags(in context: NSManagedObjectContext) -> Bool {
        var deleted = false
        
        let predicate = NSPredicate(value: true)
        let request = Tag.fetchRequest() as NSFetchRequest<Tag>
        request.predicate = predicate
        request.sortDescriptors = []
        
        let results = (try? context.fetch(request)) ?? []
        
        for tag in results where tag.noteCards.isEmpty {
            deleted = true
            context.delete(tag)
        }
        
        return deleted
    }
}


extension AppState {
    
    func isDuplicateTagName(_ name: String) -> Bool {
        let nameField = #keyPath(Tag.name)
        let predicate = NSPredicate(format: "\(nameField) =[c] %@", name)
        let request = Tag.fetchRequest() as NSFetchRequest<Tag>
        request.predicate = predicate
        request.sortDescriptors = []
        let results = (try? parentContext.fetch(request)) ?? []
        return results.isEmpty == false
    }
    
    func isDuplicateCollectionName(_ name: String) -> Bool {
        let nameField = #keyPath(NoteCardCollection.name)
        let predicate = NSPredicate(format: "\(nameField) =[c] %@", name)
        let request = NoteCardCollection.fetchRequest() as NSFetchRequest<NoteCardCollection>
        request.predicate = predicate
        request.sortDescriptors = []
        let results = (try? parentContext.fetch(request)) ?? []
        return results.isEmpty == false
    }
}









