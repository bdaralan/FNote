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
    @NSManaged private(set) var name: String
    @NSManaged private(set) var colorHex: String
    
    @NSManaged private(set) var vocabularies: Set<Vocabulary>
    @NSManaged private(set) var vocabularyCollections: Set<VocabularyCollection>
    
    /// - parameters:
    ///   - name: The name of the tag.
    ///   - colorHex: The color of the tag in hex. Must be 6 characters without # symbol.
    convenience init(name: String, colorHex: String?, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
        guard let colorHex = colorHex, colorHex.count == 6 else { return }
        self.colorHex = colorHex
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        name = ""
        colorHex = "FFFFFF"
        vocabularies = []
        vocabularyCollections = []
        recordMetadata = RecordMetadata(recordType: recordType, recordName: nil, zone: recordZone, context: managedObjectContext!)
    }
}


extension Tag {
    
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


extension Tag {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }
    
    @objc(addVocabulariesObject:)
    @NSManaged private func addToVocabularies(_ value: Vocabulary)
    
    @objc(removeVocabulariesObject:)
    @NSManaged private func removeFromVocabularies(_ value: Vocabulary)
    
    @objc(addVocabularies:)
    @NSManaged private func addToVocabularies(_ values: NSSet)
    
    @objc(removeVocabularies:)
    @NSManaged private func removeFromVocabularies(_ values: NSSet)
    
    @objc(addVocabularyCollectionsObject:)
    @NSManaged private func addToVocabularyCollections(_ value: VocabularyCollection)
    
    @objc(removeVocabularyCollectionsObject:)
    @NSManaged private func removeFromVocabularyCollections(_ value: VocabularyCollection)
    
    @objc(addVocabularyCollections:)
    @NSManaged private func addToVocabularyCollections(_ values: NSSet)
    
    @objc(removeVocabularyCollections:)
    @NSManaged private func removeFromVocabularyCollections(_ values: NSSet)
}
