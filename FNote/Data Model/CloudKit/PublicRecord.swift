//
//  PublicRecord.swift
//  FNote
//
//  Created by Dara Beng on 2/23/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


// MARK: - Record Protocol

protocol PublicRecord {
    
    static var recordType: CKRecord.RecordType { get }
    
    var recordName: String { get }
    
    /// A CKRecord newly created from the object's values.
    ///
    /// - Important: Use this to create a new record to upload.
    /// Do not use it for record modification.
    func createCKRecord() -> CKRecord
    
    init(record: CKRecord)
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


// MARK: - CKRecord Convenience

extension CKRecord {
    
    func keyedRecord<Key>(keys: Key.Type) -> KeyedRecord<Key> where Key: CodingKey {
        KeyedRecord<Key>(record: self)
    }
    
    func systemFields() -> Data {
        let encoder = NSKeyedArchiver(requiringSecureCoding: true)
        self.encodeSystemFields(with: encoder)
        return encoder.encodedData
    }
    
    convenience init?(systemFields: Data) {
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: systemFields)
            self.init(coder: unarchiver)
        } catch {
            print("⚠️ failed to unarchive CKRecord from systemFields ⚠️")
            return nil
        }
    }
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
