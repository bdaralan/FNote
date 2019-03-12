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

    @NSManaged public var accountToken: String
    
    
    convenience init(accountToken: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.accountToken = accountToken
    }
}
