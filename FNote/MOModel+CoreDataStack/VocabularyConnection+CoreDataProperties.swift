//
//  VocabularyConnection+CoreDataProperties.swift
//  FNote
//
//  Created by Dara Beng on 3/8/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


extension VocabularyConnection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VocabularyConnection> {
        return NSFetchRequest<VocabularyConnection>(entityName: "VocabularyConnection")
    }
}
