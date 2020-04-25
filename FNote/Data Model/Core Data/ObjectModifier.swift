//
//  ObjectModifier.swift
//  FNote
//
//  Created by Dara Beng on 4/25/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation
import CoreData


struct ObjectModifier<Object> where Object: NSManagedObject {
    
    /// The object's context.
    let context: NSManagedObjectContext
    
    /// The child context of the object's context.
    let modifiedContext: NSManagedObjectContext
    
    /// The object to modify.
    let object: Object
    
    /// The object that is being modified in `modifiedContext`.
    let modifiedObject: Object
    
    
    init(object: Object) {
        guard let context = object.managedObjectContext else {
            fatalError("🧨 creating ObjectModifier<\(Object.self)> with nil context 🧨")
        }
        
        self.context = context
        self.modifiedContext = context.newChildContext()
        self.object = object
        self.modifiedObject = object.get(from: modifiedContext)
    }
    
    
    func saveChanges() {
        guard modifiedObject.hasPersistentChangedValues else { return }
        modifiedContext.quickSave()
        context.quickSave()
    }
}
