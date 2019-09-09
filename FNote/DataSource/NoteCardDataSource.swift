//
//  NoteCardDataSource.swift
//  FNote
//
//  Created by Dara Beng on 9/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


/// An object data source that manage `NoteCard`.
class NoteCardDataSource: NSObject, ObjectDataSource {

    typealias Object = NoteCard
    
    var parentContext: NSManagedObjectContext
    
    var createContext: NSManagedObjectContext
    
    var updateContext: NSManagedObjectContext
    
    var fetchedResult: NSFetchedResultsController<NoteCard>
    
    var newObject: NoteCard?
    
    var updateObject: NoteCard?
    
    
    required init(parentContext: NSManagedObjectContext) {
        self.parentContext = parentContext
        createContext = parentContext.newChildContext()
        updateContext = parentContext.newChildContext()
        
        let request = NoteCard.fetchRequest() as NSFetchRequest<NoteCard>
        request.sortDescriptors = []
        
        fetchedResult = .init(
            fetchRequest: request,
            managedObjectContext: updateContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // send change to the UI when the fetchResult is changed
        // ex: an object is create, delete, or a fetch is performed
        objectWillChange.send()
    }
}
