//
//  CoreDataStack+Test.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation
import CoreData


extension CoreDataStack {
    
    static let samplePersistantContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "FNote")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition(description.type == NSInMemoryStoreType)
                                        
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        
        return container
    }()
    
    static var sampleContext: NSManagedObjectContext {
        samplePersistantContainer.viewContext
    }
}

