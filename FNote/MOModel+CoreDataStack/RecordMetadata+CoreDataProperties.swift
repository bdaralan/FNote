//
//  RecordMetadata+CoreDataProperties.swift
//  FNote
//
//  Created by Dara Beng on 3/8/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


extension RecordMetadata {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordMetadata> {
        return NSFetchRequest<RecordMetadata>(entityName: "RecordMetadata")
    }
}
