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
    typealias DatabaseKey = CodingKey
    
    /// `CKRecord`'s integer `enum` value.
    /// - warning: Since their values are store in the database, they must not be changed or reordered carelessly.
    typealias DatabaseIntegerEnum = Int
    
    /// Database Record Type. This must not be changed without re-configure the whole database.
    var recordType: CKRecord.RecordType { get }
    
    /// Database Record Zone
    var recordZone: CKRecordZone { get }
    
    /// Database `CKRecord` metadata.
    var recordMetadata: RecordMetadata { get }
    
    /// The key-value pairs of the local record to be stored in the database.
    func recordValuesForServerKeys() -> [String: Any]
}
