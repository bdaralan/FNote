//
//  TagDataSource.swift
//  FNote
//
//  Created by Veronica Sumariyanto on 9/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData

// An object data source that manages 'Tag'
class TagDataSource: NSObject, ObjectDataSource {
    
    // The type of object that the data source will manage
    typealias Object = Tag
    
    // Parent context that can send changes to the database
    var parentContext: NSManagedObjectContext
    
    // Context to create a new object
    var createContext: NSManagedObjectContext
    
    // Context to read/update existing object
    var updateContext: NSManagedObjectContext
    
    // Fetch result controller that fetches objects from 'parentContext'
    var fetchedResult: NSFetchedResultsController<Tag>
    
    // A new tag object
    var newObject: Tag?
    
    // A updated tag object
    var updateObject: Tag?
    
    // Initializing the data source with the given context
    // what it needs to conform to the objectdatasource
    required init(parentContext: NSManagedObjectContext) {
        self.parentContext = parentContext
        createContext = parentContext.newChildContext()
        updateContext = parentContext.newChildContext()
        
        let request = Tag.fetchRequest() as NSFetchRequest<Tag>
        // how to sort, no sort, just grab
        // make sure that fetchedResult is initialized
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
    
    // func deals with the UI, to reflect the changes made to the object
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send();
    }
}
