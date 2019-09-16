//
//  CoreDataStack+Sample.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation
import CoreData


// MARK: Caching Protocol

protocol CoreDataStackCurrentManagedObject {}


extension CoreDataStackCurrentManagedObject {
    
    static private var kCurrentURIData: String { "\(Self.self).kCurrentURIData" }
    
    static var nCurrentObjectIDDidChange: Notification.Name { .init(kCurrentURIData) }
    
    static func setCurrent(objectID: NSManagedObjectID?) {
        let defaults = UserDefaults.standard
        let uriData = objectID?.uriRepresentation().dataRepresentation
        defaults.setValue(uriData, forKey: kCurrentURIData)
        NotificationCenter.default.post(name: nCurrentObjectIDDidChange, object: objectID)
    }
    
    static func current() -> NSManagedObjectID? {
        let defaults = UserDefaults.standard
        guard let uriData = defaults.data(forKey: kCurrentURIData) else { return nil }
        
        guard let uri = URL(dataRepresentation: uriData, relativeTo: nil) else { return nil }
        let storeCoodinator = CoreDataStack.current.persistentContainer.persistentStoreCoordinator
        guard let objectID =  storeCoodinator.managedObjectID(forURIRepresentation: uri) else { return nil }
        return objectID
    }
    
    static func isCurrent(objectID: NSManagedObjectID) -> Bool {
        objectID == current()
    }
}


// MARK: - Sample Data

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

