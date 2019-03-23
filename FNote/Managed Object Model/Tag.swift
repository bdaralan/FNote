//
//  Tag+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 3/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import CloudKit
import CoreData


public class Tag: NSManagedObject, LocalRecord {
    
    var recordType: CKRecord.RecordType { return "Tag" }
    var recordZone: CKRecordZone { return CloudKitService.ckVocabularyCollectionZone }

    @NSManaged private(set) var recordMetadata: RecordMetadata
    @NSManaged private(set) var user: User
    @NSManaged private(set) var name: String
    @NSManaged private(set) var colorHex: String
    
    @NSManaged private(set) var vocabularies: Set<Vocabulary>
    @NSManaged private(set) var vocabularyCollections: Set<VocabularyCollection>
    
    /// - parameters:
    ///   - name: The name of the tag.
    ///   - colorHex: The color of the tag in hex. Must be 6 characters without # symbol.
    convenience init(name: String, colorHex: String?, user: User) {
        self.init(context: user.managedObjectContext!)
        self.user = user
        self.name = name
        self.colorHex = colorHex?.count == 6 ? colorHex! : "FFFFFF"
        vocabularies = []
        vocabularyCollections = []
        recordMetadata = RecordMetadata(recordType: recordType, recordName: nil, zone: recordZone, context: managedObjectContext!)
    }
    
    #warning("TODO: impelement check for duplicate before rename")
    func rename(_ name: String) {
        self.name = name
    }
}


extension Tag {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }
    
    func recordValuesForServerKeys() -> [String : Any] {
        return [
            Key.name.stringValue: name,
            Key.colorHex.stringValue: colorHex
        ]
    }
    
    enum Key: LocalRecord.DatabaseKey {
        case name
        case colorHex
    }
}
