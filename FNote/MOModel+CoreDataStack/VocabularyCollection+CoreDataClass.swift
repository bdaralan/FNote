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
    
    @NSManaged public var recordSystemFields: Data!
    @NSManaged public var name: String
    @NSManaged private(set) var vocabularies: Set<Vocabulary>
    
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        initRecordSystemFields()
        name = ""
        vocabularies = []
    }
    
    func recordValuesForServerKeys() -> [String : Any] {
        return [Key.name.stringValue: name]
    }
    
    enum Key: LocalRecord.ServerKey {
        case name
    }
}
