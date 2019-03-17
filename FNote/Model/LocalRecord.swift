//
//  LocalRecord.swift
//  FNote
//
//  Created by Dara Beng on 2/3/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CloudKit
import CoreData


protocol LocalRecord: class {
    
    /// `CKRecord` key-value-pair key.
    typealias ServerKey = CodingKey
    
    /// `CKRecord`'s integer `enum` value.
    /// - warning: Since their values are store in the database, they must not be changed or reordered carelessly.
    typealias ServerIntegerEnum = Int16
    
    /// Database Record Type
    var recordType: CKRecord.RecordType { get }
    
    /// Database Record Zone
    var recordZone: CKRecordZone { get }
    
    /// Database `CKRecord` metadata.
    var recordMetadata: RecordMetadata { get }
    
    /// The key-value pairs of the local record to be stored in the database.
    func recordValuesForServerKeys() -> [String: Any]
}
