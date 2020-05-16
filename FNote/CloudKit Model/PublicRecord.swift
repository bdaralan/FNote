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
    
    /// The current `CKRecord` that create this object.
    var record: CKRecord? { get }
    
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


extension RecordModifier {
    
    // MARK: Setter
    
    /// Set a cascade delete rule for the record.
    /// - Parameters:
    ///   - referenceID: The record that will trigger the deletion when it is deleted.
    ///   - field: The field to store the reference record.
    func setCascadeDelete(referenceID: String, field: Field) {
        let recordID = CKRecord.ID(recordName: referenceID)
        let recordRef = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
        record[field.stringValue] = recordRef
    }
    
    // MARK: Getter
    
    func string(for field: Field) -> String? {
        self[field] as? String
    }
    
    func integer(for field: Field) -> Int? {
        self[field] as? Int
    }
    
    func integer64(for field: Field) -> Int64? {
        self[field] as? Int64
    }
    
    func bool(for field: Field, default value: Bool = false) -> Bool {
        self[field] as? Bool ?? value
    }
    
    func data(for field: Field) -> Data? {
        self[field] as? Data
    }
    
    func stringList(for field: Field) -> [String] {
        self[field] as? [String] ?? []
    }
    
    func asset(for field: Field) -> CKAsset? {
        self[field] as? CKAsset
    }
}


// MARK: Record Formatter

struct PublicRecordFormatter {
    
    static let databaseTagSeparator = "|"
    
    static let databaseTagArraySeparator = " \(databaseTagSeparator) "
    
    
    /// Format the tag to a valid string for the database.
    /// - Parameter tag: The tag to validate.
    /// - Returns: A valid format string, `nil` if invalid.
    func validDatabaseTag(_ tag: String) -> String? {
        let string = tag.replacingOccurrences(of: Self.databaseTagSeparator, with: "").trimmed().lowercased()
        return string.isEmpty ? nil : string
    }
    
    func validDatabaseTags(_ tags: [String]) -> [String] {
        tags.compactMap({ validDatabaseTag($0) })
    }
    
    func databaseTags(fromLocalTags tags: [String]) -> String {
        let validTags = validDatabaseTags(tags)
        return validTags.joined(separator: Self.databaseTagArraySeparator)
    }
    
    func localTags(fromDatabaseTags tags: String) -> [String] {
        if tags.isEmpty { return [] }
        return tags.components(separatedBy: Self.databaseTagArraySeparator)
    }
    
    /// Get the correct list format.
    /// - Parameter list: The list to save to the database.
    /// - Returns: `nil` if the list is empty.
    func validDatabaseList(_ list: [String]) -> [String]? {
        return list.isEmpty ? nil : list
    }
}
