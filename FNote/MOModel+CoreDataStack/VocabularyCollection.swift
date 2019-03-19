//
//  VocabularyCollection+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 1/21/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import CloudKit
import CoreData


public class VocabularyCollection: NSManagedObject, LocalRecord {
    
    var recordType: CKRecord.RecordType { return "VocabularyCollection" }
    var recordZone: CKRecordZone { return CloudKitService.ckVocabularyCollectionZone }
    
    @NSManaged private(set) var recordMetadata: RecordMetadata
    @NSManaged public var name: String
    @NSManaged private(set) var vocabularies: Set<Vocabulary>
    
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        name = ""
        vocabularies = []
        recordMetadata = RecordMetadata(recordType: recordType, recordName: nil, zone: recordZone, context: managedObjectContext!)
    }
}


extension VocabularyCollection {
    
    func recordValuesForServerKeys() -> [String : Any] {
        return [Key.name.stringValue: name]
    }
    
    enum Key: LocalRecord.DatabaseKey {
        case name
    }
}


extension VocabularyCollection {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<VocabularyCollection> {
        return NSFetchRequest<VocabularyCollection>(entityName: "VocabularyCollection")
    }
    
    @objc(addVocabulariesObject:)
    @NSManaged private func addToVocabularies(_ value: Vocabulary)
    
    @objc(removeVocabulariesObject:)
    @NSManaged private func removeFromVocabularies(_ value: Vocabulary)
    
    @objc(addVocabularies:)
    @NSManaged private func addToVocabularies(_ values: NSSet)
    
    @objc(removeVocabularies:)
    @NSManaged private func removeFromVocabularies(_ values: NSSet)
}
