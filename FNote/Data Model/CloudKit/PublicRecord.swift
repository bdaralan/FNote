//
//  PublicRecord.swift
//  FNote
//
//  Created by Dara Beng on 2/23/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


// MARK: - Public Record

/// A protocol used to identify basic properties of a CKRecord.
///
protocol PublicRecord {
    
    /// An enum list all CKRecord's fields.
    associatedtype RecordFields: RecordField
    
    /// `CKRecord` `recordType`.
    static var recordType: CKRecord.RecordType { get }
    
    /// `CKRecord` `recordName`.
    var recordName: String { get }
    
    /// Create `PublicRecord` with `CKRecord`.
    /// - Parameter record: a `CKRecord` that matches the type of the `PublicRecord`.
    init(record: CKRecord)
    
    /// A `CKRecord` newly created from the object's values.
    ///
    /// - Warning: Use this to create a new record to upload.
    /// Do not use it to re-create a record for modification.
    func createCKRecord() -> CKRecord
}


// MARK: - Record Field

/// A protocol used to identity enum as CKRecord's fields.
///
protocol RecordField: CodingKey {}


// MARK: - Record Modifier

/// An object used to access `CKRecord` with a type-safe enum conforming to `RecordField`.
///
struct RecordModifier<Field> where Field: RecordField {
    
    let record: CKRecord
    
    init(record: CKRecord) {
        self.record = record
    }
    
    subscript(field: Field) -> Any? {
        get { record[field.stringValue] }
        set { record[field.stringValue] = newValue as? CKRecordValue }
    }
}
