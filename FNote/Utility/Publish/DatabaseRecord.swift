//
//  PublishableRecord.swift
//  FNote
//
//  Created by Dara Beng on 2/23/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


// MARK: - Record Protocol

protocol DatabaseRecord {
    
    static var recordType: CKRecord.RecordType { get }
    
    var recordName: String { get }
    
    /// A KeyedCKRecord with the object's values.
    func createCKRecord() -> CKRecord
    
    init(record: CKRecord)
}


// MARK: - Date Formatter

extension Date {
    
    static private var dateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        return formatter
    }
    
    static func databaseDate(from iso8601: String) -> Date? {
        Self.dateFormatter.date(from: iso8601)
    }
    
    var databaseDateString: String {
        Self.dateFormatter.string(from: self)
    }
}


// MARK: - Record Helper Class

class KeyedRecord<Key> where Key: CodingKey {
    
    let record: CKRecord
    
    init(record: CKRecord) {
        self.record = record
    }
    
    subscript(key: Key) -> Any? {
        get { record[key.stringValue] }
        set { record[key.stringValue] = newValue as? CKRecordValue }
    }
}
