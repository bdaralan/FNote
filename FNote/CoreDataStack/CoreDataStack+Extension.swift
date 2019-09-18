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
    
    static let sampleContext = CoreDataStack.current.mainContext.newChildContext()
}

