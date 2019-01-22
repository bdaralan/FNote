//
//  User+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 1/21/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


public class User: NSManagedObject {

    @NSManaged public var userID: String
    @NSManaged public var collections: Set<VocabularyCollection>
    
    #warning("TODO: need to implement syncing user id with icloud")
}
