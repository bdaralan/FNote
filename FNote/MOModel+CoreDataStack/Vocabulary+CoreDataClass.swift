//
//  Vocabulary+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 1/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import CloudKit
import CoreData


public class Vocabulary: NSManagedObject, LocalRecord {
    
    var recordType: CKRecord.RecordType { return "Vocabulary" }
    var recordZone: CKRecordZone { return CloudKitService.ckVocabularyCollectionZone }

    @NSManaged public var recordSystemFields: Data!
    @NSManaged public var native: String
    @NSManaged public var translation: String
    @NSManaged public var note: String
    @NSManaged public var politeness: String
    @NSManaged public var isFavorited: Bool
    @NSManaged private(set) var relations: Set<Vocabulary>
    @NSManaged private(set) var alternatives: Set<Vocabulary>
    @NSManaged private(set) var collection: VocabularyCollection
    
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        initRecordSystemFields()
        native = ""
        translation = ""
        note = ""
        politeness = Politeness.unknown.string
        relations = []
        alternatives = []
    }
    
    func recordValuesForServerKeys() -> [String : Any] {
        return [
            Key.native.stringValue: native,
            Key.translation.stringValue: translation,
            Key.note.stringValue: note,
            Key.politeness.stringValue: politeness
        ]
    }
    
    enum Key: LocalRecord.ServerKey {
        case native
        case translation
        case note
        case politeness
        case relations
        case alternatives
    }
    
    /// - warning: These values should not be changed because they will be stored in the database.
    enum Politeness: Int, CaseIterable {
        case unknown
        case informal
        case neutral
        case formal
        
        var string: String {
            switch self {
            case .unknown: return "Unknown"
            case .informal: return "Informal"
            case .neutral: return "Neutral"
            case .formal: return "Formal"
            }
        }
    }
    
    /// - warning: These values should not be changed because they will be stored in the database.
    enum ConnectionType: Int {
        case relation
        case alternative
    }
    
    #warning("TODO: need init that has to set collection")
}


extension Vocabulary {
    
    func setCollection(_ collection: VocabularyCollection) {
        #warning("TODO: need logic for cross collection")
        self.collection = collection
    }
    
    /// Locally make a connection between two vocabularies.
    /// - returns: A `CKRecord` of record type `VocabularyConnection`.
    func setConnection(first: Vocabulary, second: Vocabulary, type: ConnectionType) -> CKRecord? {
        #warning("TODO: implement")
        switch type {
        case .relation where !first.relations.contains(second):
            return nil
        case .alternative where !first.alternatives.contains(second):
            return nil
        default:
            return nil
        }
    }
}
