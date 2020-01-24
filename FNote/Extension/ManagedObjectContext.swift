//
//  Extension+ManagedObject.swift
//  FNote
//
//  Created by Dara Beng on 9/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//


import CoreData


typealias ManagedObjectChildContext = NSManagedObjectContext


extension NSManagedObjectContext {
    
    static let sample = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    /// Create a child context and set itself as the parent.
    func newChildContext(type: NSManagedObjectContextConcurrencyType = .mainQueueConcurrencyType, mergesChangesFromParent: Bool = true) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: type)
        context.parent = self
        context.automaticallyMergesChangesFromParent = mergesChangesFromParent
        return context
    }
    
    /// Quickly save the context by assuming that the everything is valid.
    func quickSave() {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            fatalError("failed to save context with error: \(error)")
        }
    }
}


extension NSManagedObject {
    
    /// Get the object from another context using it `objectID`.
    func get(from context: NSManagedObjectContext) -> Self {
        context.object(with: objectID) as! Self
    }
}
