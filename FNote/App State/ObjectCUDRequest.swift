//
//  ObjectCUDRequest.swift
//  FNote
//
//  Created by Dara Beng on 1/22/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CoreData


protocol ObjectCUDRequest {
    
    associatedtype Object: NSManagedObject
    
    /// Change current objects context to the given context.
    /// - Parameter context: The context to apply to.
    func changeContext(_ context: NSManagedObjectContext)
    
    /// Set the value in the info to the given object.
    /// - Parameter object: The object to assign values.
    func update(_ object: Object)
}


enum ObjectCUDResult<T: NSManagedObject> {
    case created(T, ManagedObjectChildContext)
    case updated(T, ManagedObjectChildContext)
    case deleted(ManagedObjectChildContext)
    case unchanged
    case failed
}
