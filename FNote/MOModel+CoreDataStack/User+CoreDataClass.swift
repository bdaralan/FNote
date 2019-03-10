//
//  User+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 3/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


public class User: NSManagedObject {

    @NSManaged public var userID: String
    
    
    convenience init(userID: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.userID = userID
    }
}
