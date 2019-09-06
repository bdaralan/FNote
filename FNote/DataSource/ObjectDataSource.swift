//
//  ObjectDataSource.swift
//  FNote
//
//  Created by Dara Beng on 9/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


/// A data source protocol for fetching, creating, reading, updating, and deleting object.
protocol ObjectDataSource: ObservableObject, NSFetchedResultsControllerDelegate {
    
    /// The type of object that the data source will managed.
    associatedtype Object: NSManagedObject & ObjectValidatable
    
    /// Initialize data source with the given context.
    /// - Parameter parentContext: The context that can propagate changes to database.
    init(parentContext: NSManagedObjectContext)
    
    
    // MARK: Property
    
    /// The parenet context that can propagate changes to database.
    var parentContext: NSManagedObjectContext { get }
    
    /// The context used to create new object.
    var createContext: NSManagedObjectContext { get }
    
    /// The context used to read and update existing object.
    var updateContext: NSManagedObjectContext { get }
    
    /// A fetch result controller used to fetch objects from the `parentContext`
    var fetchedResult: NSFetchedResultsController<Object> { get }
    
    /// A new object to be created.
    ///
    /// - Warning: This object should NOT be set directly. See the following methods.
    /// - This object is `nil` until `prepareNewObject()` is called.
    /// - Call `discardNewObject()` to set it to `nil`.
    var newObject: Object? { set get }
    
    /// An object being updated.
    ///
    /// - Warning: This object should NOT be set directly. See `setUpdateObject(_:)` method.
    var updateObject: Object? { set get }
    
    
    // MARK: Method
    
    /// Save the `newObject` to its context.
    func saveNewObject() -> ObjectSaveResult
    
    /// Save changes of the `updateObject` to its context.
    func saveUpdateObject() -> ObjectSaveResult
}


// MARK: - Fetch Method

extension ObjectDataSource {
    
    /// Perform fetch on the `fetchResult`.
    /// - Parameter request: The request to perform or `nil` to perform the current request.
    func performFetch(_ request: NSFetchRequest<Object>? = nil) {
        if let request = request {
            fetchedResult.fetchRequest.predicate = request.predicate
            fetchedResult.fetchRequest.sortDescriptors = request.sortDescriptors
        }
        
        do {
            try fetchedResult.performFetch()
        } catch {
            print(error)
        }
    }
}


// MARK: - Default Implementation

extension ObjectDataSource {
    
    func saveNewObject() -> ObjectSaveResult {
        guard let object = newObject, object.isValid() else { return .failed }
        
        object.objectWillChange.send() // tell UI to update
        
        if object.hasChangedValues() {
            object.validateData()
            saveCreateContext()
            return .saved
        } else {
            discardCreateContext()
            return .unchanged
        }
    }
    
    func saveUpdateObject() -> ObjectSaveResult {
        guard let object = updateObject, object.isValid() else { return .failed }
        
        object.objectWillChange.send() // tell UI to update
        
        if object.hasChangedValues() {
            object.validateData()
            saveUpdateContext()
            return .saved
        } else {
            discardUpdateContext()
            return .unchanged
        }
    }
}


// MARK: - Object CRUD Method

extension ObjectDataSource {
    
    /// Assign `newObject` a new value if it is `nil`.
    func prepareNewObject() {
        guard newObject == nil else { return }
        newObject = Object(context: createContext)
    }
    
    /// Set `newObject` to `nil`.
    func discardNewObject() {
        guard newObject != nil else { return }
        newObject = nil
    }
    
    /// Get the same object from `updateContext`.
    /// - Parameter object: The object to read.
    func readObject(_ object: Object) -> Object {
        updateContext.object(with: object.objectID) as! Object
    }
    
    /// Assign object to the `updateObject`
    /// - Parameter object: The object to assign. It must be from the `updateContext`.
    func setUpdateObject(_ object: Object?) {
        if let object = object, object.managedObjectContext === updateContext {
            updateObject = object
        } else {
            updateObject = nil
        }
    }
    
    /// Delete object's from the context.
    /// - Parameter object: The object to delete. Must be in `parentContext` or `updateContext`.
    /// - Parameter saveContext: `true` to save the context.
    func delete(_ object: Object, saveContext: Bool) {
        guard let context = object.managedObjectContext else { return }
        guard context === parentContext || context === updateContext else { return }
        context.delete(object)
        
        guard saveContext else { return }
        context.quickSave()
        
        guard context === updateContext else { return }
        parentContext.quickSave()
    }
}


// MARK: - Save Context Method

extension ObjectDataSource {
    
    /// Save `createContext`'s changes to the `parentContext`.
    func saveCreateContext() {
        saveContext(createContext)
    }
    
    /// Discard `createContext`'s changes since last save.
    func discardCreateContext() {
        discardContext(createContext)
    }
    
    /// Save `updateContext`'s changes to the `parentContext`.
    func saveUpdateContext() {
        saveContext(updateContext)
    }
    
    /// Discard `updateContext`'s changes since last save.
    func discardUpdateContext() {
        discardContext(updateContext)
    }
    
    /// Save context's changes to the `parentContext`.
    /// - Parameter context: The `createContext` or `updateContext`.
    private func saveContext(_ context: NSManagedObjectContext) {
        guard context === createContext || context === updateContext else { return }
        guard context.hasChanges else { return }
        context.quickSave()
        parentContext.quickSave()
    }
    
    /// Discard changes of the given context.
    /// - Parameter context: The `createContext` or `updateContext`.
    private func discardContext(_ context: NSManagedObjectContext) {
        guard context === createContext || context === updateContext else { return }
        guard context.hasChanges else { return }
        context.rollback()
    }
}


// MARK: - Enum

/// An object's save result.
enum ObjectSaveResult {
    
    /// A result returns when an object is saved.
    case saved
    
    /// A result returns when an object is failed to save.
    case failed
    
    /// A result returns when there is no changes to save.
    case unchanged
}
