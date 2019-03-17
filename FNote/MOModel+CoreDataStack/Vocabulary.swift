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

    @NSManaged private(set) var recordMetadata: RecordMetadata
    @NSManaged public var native: String
    @NSManaged public var translation: String
    @NSManaged public var note: String
    @NSManaged public var isFavorited: Bool
    @NSManaged private var politenessValue: Int16
    @NSManaged private(set) var collection: VocabularyCollection
    @NSManaged private(set) var relations: Set<Vocabulary>
    @NSManaged private(set) var alternatives: Set<Vocabulary>
    
    @NSManaged private(set) var connections: Set<VocabularyConnection>
    @NSManaged private(set) var sourceOf: VocabularyConnection?
    @NSManaged private(set) var targetOf: VocabularyConnection?
    
    var politeness: Politeness {
        set { politenessValue = newValue.rawValue }
        get { return Politeness(rawValue: politenessValue) ?? .undecided }
    }

    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        native = ""
        translation = ""
        note = ""
        politeness = Politeness.undecided
        relations = []
        alternatives = []
        recordMetadata = RecordMetadata(recordType: recordType, recordName: nil, zone: recordZone, context: managedObjectContext!)
    }
    
    convenience init(collection: VocabularyCollection, context: NSManagedObjectContext) {
        self.init(context: context)
        self.collection = collection
        #warning("TODO: set collection and reconfigure its CKRecord")
    }
}


extension Vocabulary {
    
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
    
    /// Vocabulary politeness value.
    /// - warning: These values should not be changed because they must be matched with the database.
    enum Politeness: LocalRecord.ServerIntegerEnum, CaseIterable {
        case undecided
        case informal
        case neutral
        case formal
        
        var string: String {
            switch self {
            case .undecided: return "Undecided"
            case .informal: return "Informal"
            case .neutral: return "Neutral"
            case .formal: return "Formal"
            }
        }
    }
    
    #warning("TODO: need init that has to set collection")
}


extension Vocabulary {
    
    /// Add connection between the given vocabulary and create a connection object.
    /// - returns: The `VocabularyConnection` created.
    func addConnection(with vocabulary: Vocabulary, type: VocabularyConnection.ConnectionType) -> VocabularyConnection {
        switch type {
        case .related:
            addToRelations(vocabulary)
            vocabulary.addToRelations(self)
        case .alternative:
            addToAlternatives(vocabulary)
            vocabulary.addToAlternatives(self)
        case .unknown: ()
        }
        
        let connection = VocabularyConnection(type: type, source: self, target: vocabulary, context: managedObjectContext!)
        addToConnections(connection)
        return connection
    }
    
    /// Remove the connection between the given vocabulary and delete the connection object.
    /// - returns: The deleted `VocabularyConnection` if the connections was removed. Otherwise, `nil`.
    func removeConnection(with vocabulary: Vocabulary, type: VocabularyConnection.ConnectionType) -> VocabularyConnection? {
        for connection in connections where connection.type == type && connection.isConnection(of: (self, vocabulary)) {
            switch type {
            case .related:
                self.removeFromAlternatives(vocabulary)
                vocabulary.removeFromAlternatives(self)
                managedObjectContext?.delete(connection)
                return connection
            case .alternative:
                self.removeFromAlternatives(vocabulary)
                vocabulary.removeFromAlternatives(self)
                managedObjectContext?.delete(connection)
                return connection
            default:
                return nil
            }
        }
        return nil
    }
}