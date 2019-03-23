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
    @NSManaged private(set) var user: User
    @NSManaged private(set) var name: String
    @NSManaged private(set) var vocabularies: Set<Vocabulary>
    @NSManaged private(set) var tags: Set<Tag>
    
    
    convenience init(user: User, name: String) {
        self.init(context: user.managedObjectContext!)
        self.user = user
        self.name = name
        vocabularies = []
        tags = []
        recordMetadata = RecordMetadata(recordType: recordType, recordName: nil, zone: recordZone, context: managedObjectContext!)
    }
    
    #warning("TODO: impelement check for duplicate before rename")
    func rename(_ name: String) {
        self.name = name
    }
}


extension VocabularyCollection {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<VocabularyCollection> {
        return NSFetchRequest<VocabularyCollection>(entityName: "VocabularyCollection")
    }
    
    func recordValuesForServerKeys() -> [String : Any] {
        return [Key.name.stringValue: name]
    }
    
    enum Key: LocalRecord.DatabaseKey {
        case name
    }
}
