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
    
    /// Database Record Type
    var recordType: CKRecord.RecordType { get }
    
    /// Database Record Zone
    var recordZone: CKRecordZone { get }
    
    /// Database `CKRecord` metadata.
    /// - note: Must be initialized. See `initRecordSystemFields()`.
    var recordSystemFields: Data! { set get }
    
    /// The key-value pairs of the local record to be stored in the database.
    func recordValuesForServerKeys() -> [String: Any]
}


extension LocalRecord {
    
    /// Update record system fields with the new record.
    /// - note: The method will ignore if the `recordID`s does not match.
    func updateSystemFields(with record: CKRecord) {
        guard record.recordID == emptyRecord().recordID else { return }
        recordSystemFields = Self.recordSystemFields(of: record)
    }
    
    /// The `CKRecord` with only its `recordSystemFields` metadata.
    func emptyRecord() -> CKRecord {
        let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: recordSystemFields)
        guard let coder = unarchiver, let record = CKRecord(coder: coder) else {
            fatalError("failed to unarchive cloudkit system fields!!!")
        }
        return record
    }
}


extension LocalRecord {
    
    /// Call this method on `init` to initialize `recordSystemFields`.
    /// - note: The method will do nothing if `recordSystemFields` has already been initialized.
    func initRecordSystemFields() {
        guard recordSystemFields == nil else { return }
        let recordID = CKRecord.ID(zoneID: recordZone.zoneID)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        recordSystemFields = Self.recordSystemFields(of: record)
    }
    
    /// Encodes the record's `systemFields` as `Data`.
    static func recordSystemFields(of record: CKRecord) -> Data {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: coder)
        return coder.encodedData
    }
}
