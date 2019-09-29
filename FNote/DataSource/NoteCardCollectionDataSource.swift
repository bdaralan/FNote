//
//  NoteCardCollectionDataSource.swift
//  FNote
//
//  Created by Brittney Witts on 9/10/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData

// An object data source that manages "NoteCard Collection"
class NoteCardCollectionDataSource: NSObject, ObjectDataSource {

    // The type of object that the data source will manage
    typealias Object = NoteCardCollection
    
    // Parent context that can send changes to the database
    var parentContext: NSManagedObjectContext
    
    // Context to create a new object
    var createContext: NSManagedObjectContext
    
    // Context to read/update existing object
    var updateContext: NSManagedObjectContext
    
    // Fetch result controller that fethces objects from 'parentContext'
    var fetchedResult: NSFetchedResultsController<NoteCardCollection>
    
    // New NoteCardCollection object
    var newObject: NoteCardCollection?
    
    // Updated tag object
    var updateObject: NoteCardCollection?
    
    // Initializing the data source with the given context
    required init(parentContext: NSManagedObjectContext) {
        self.parentContext = parentContext
        createContext = parentContext.newChildContext()
        updateContext = parentContext.newChildContext()
        
        let request = NoteCardCollection.fetchRequest() as NSFetchRequest<NoteCardCollection>
        
        // how to sort, no sort, or just fetch
        request.sortDescriptors = []
        
        fetchedResult = .init(
            fetchRequest: request,
            managedObjectContext: updateContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        fetchedResult.delegate = self
    }
    
    // Function deals with the UI to reflect the changes made to the object
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send();
    }
    
}
