//
//  RecordMetadata+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 3/8/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import CoreData
import CloudKit


public class RecordMetadata: NSManagedObject {

    @NSManaged private(set) var systemFields: Data
    @NSManaged private(set) var recordType: String
    @NSManaged private(set) var recordName: String
    @NSManaged private(set) var zoneName: String
    
    @NSManaged private(set) var vocabulary: Vocabulary?
    @NSManaged private(set) var vocabularyConnection: VocabularyConnection?
    @NSManaged private(set) var vocabularyCollection: VocabularyCollection?
    
    convenience init(recordType: CKRecord.RecordType, recordName: String?, zone: CKRecordZone, context: NSManagedObjectContext) {
        self.init(context: context)
        let recordID: CKRecord.ID
        if let recordName = recordName {
            recordID = CKRecord.ID(recordName: recordName, zoneID: zone.zoneID)
        } else {
            recordID = CKRecord.ID(zoneID: zone.zoneID)
        }
        let record = CKRecord(recordType: recordType, recordID: recordID)
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: coder)
        self.systemFields = coder.encodedData
        self.recordType = recordType
        self.recordName = record.recordID.recordName
        self.zoneName = zone.zoneID.zoneName
    }
    
    /// Update `systemFields` with an up to date record.
    /// - parameter record: An up to date record.
    /// - returns: `true` if the record name matched. Otherwise `false`.
    @discardableResult func update(with record: CKRecord) -> Bool {
        guard record.recordType == recordType, record.recordID.recordName == recordName else { return false }
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: coder)
        systemFields = coder.encodedData
        return true
    }
    
    /// The `CKRecord` from the encoded `systemFields`.
    func ckRecord() -> CKRecord {
        guard let coder = try? NSKeyedUnarchiver(forReadingFrom: systemFields), let record = CKRecord(coder: coder) else {
            fatalError("\(self) failed to unarchive cloudkit system fields!!!")
        }
        return record
    }
}
