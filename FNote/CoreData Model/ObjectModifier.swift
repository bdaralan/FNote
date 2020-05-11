//
//  ObjectModifier.swift
//  FNote
//
//  Created by Dara Beng on 4/25/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation
import CoreData


/// An object used to modify `ManagedObject`
///
/// The modifier provides a way to modify a given object but on a different context.
///
/// It also provides a `delete()` and `save()` methods to commit the changes.
///
/// - Note: The `Object` should extends `ObjectModifier` to add setter or getter functionality.
///
struct ObjectModifier<Object> where Object: NSManagedObject {
    
    // MARK: Property
    
    /// The mode of the modifier.
    var mode: Mode
    
    /// A value indicates whether to use separate contexts.
    ///
    /// - When `true`, `originalContext` is the parent context of `modifiedContext`.
    /// - When `false`, `originalContext` and `modifiedContext` is the same.
    let useSeparateContext: Bool
    
    /// The context that the save will apply to.
    ///
    /// See `Mode` for more info.
    let originalContext: NSManagedObjectContext
    
    /// The child context of the object's context.
    ///
    /// This context has `automaticallyMergesChangesFromParent = true`.
    let modifiedContext: NSManagedObjectContext
    
    /// The object that is being modified in `modifiedContext`.
    let modifiedObject: Object
    
    /// The given, unmodified object.
    ///
    /// This always `nil` for `.create` mode.
    let originalObject: Object?
    
    
    // MARK: Constructor
    
    /// Construct with mode.
    /// - Parameters:
    ///   - mode: The mode to use.
    ///   - useSeparateContext: The default is `true`. See the property's documentation for more details.
    init(_ mode: Mode, useSeparateContext: Bool = true) {
        self.mode = mode
        self.useSeparateContext = useSeparateContext
        
        switch mode {
        case .create(let context):
            originalContext = context
            
        case .update(let object):
            guard let context = object.managedObjectContext else {
                fatalError("🧨 creating ObjectModifier<\(Object.self)> with nil context 🧨")
            }
            originalContext = context
        }
        
        if useSeparateContext {
            modifiedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            modifiedContext.parent = originalContext
            modifiedContext.automaticallyMergesChangesFromParent = true
        } else {
            modifiedContext = originalContext
        }
        
        switch mode {
        case .create:
            originalObject = nil
            modifiedObject = Object(context: modifiedContext)
            
        case .update(let object):
            originalObject = object
            modifiedObject = object.get(from: modifiedContext)
        }
    }
    
    
    // MARK: Method
    
    func save() {
        modifiedContext.quickSave()
        originalContext.quickSave()
    }
    
    func delete() {
        modifiedContext.delete(modifiedObject)
    }
    
    
    // MARK: Mode Enum
    
    enum Mode {
        /// A create mode that will save the new object to the given context on saved.
        case create(in: NSManagedObjectContext)
        
        /// An update mode that will save the changes to the give object's context on saved.
        case update(Object)
    }
}
