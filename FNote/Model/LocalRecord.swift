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
    
    /// `CKRecord` string value.
    typealias ServerStringValue = String
    
    /// Database Record Type
    var recordType: CKRecord.RecordType { get }
    
    /// Database Record Zone
    var recordZone: CKRecordZone { get }
    
    /// Database `CKRecord` metadata.
    var recordMetadata: RecordMetadata { get }
    
    /// The key-value pairs of the local record to be stored in the database.
    func recordValuesForServerKeys() -> [String: Any]
}
