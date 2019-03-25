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
    @NSManaged private var politenessValue: Int64
    @NSManaged private(set) var collection: VocabularyCollection
    @NSManaged private(set) var relations: Set<Vocabulary>
    @NSManaged private(set) var alternatives: Set<Vocabulary>
    @NSManaged private(set) var connections: Set<VocabularyConnection>
    @NSManaged private(set) var tags: Set<Tag>
    
    @NSManaged private(set) var sourceOf: VocabularyConnection?
    @NSManaged private(set) var targetOf: VocabularyConnection?
    
    var politeness: Politeness {
        set { politenessValue = Int64(newValue.rawValue) }
        get { return Politeness(rawValue: Int(politenessValue)) ?? .undecided }
    }
    
    
    convenience init(collection: VocabularyCollection, context: NSManagedObjectContext) {
        self.init(context: context)
        self.collection = collection
        native = ""
        translation = ""
        note = ""
        politeness = .undecided
        relations = []
        alternatives = []
        tags = []
        connections = []
        recordMetadata = RecordMetadata(recordType: recordType, recordName: nil, zone: recordZone, context: managedObjectContext!)
        #warning("TODO: set collection and reconfigure its CKRecord")
    }
    
    func tagNames() -> [String] {
        return tags.map({ $0.name })
    }
}


extension Vocabulary {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vocabulary> {
        return NSFetchRequest<Vocabulary>(entityName: "Vocabulary")
    }
    
    func recordValuesForServerKeys() -> [String : Any] {
        return [
            Key.native.stringValue: native,
            Key.translation.stringValue: translation,
            Key.note.stringValue: note,
            Key.politeness.stringValue: politeness
        ]
    }
    
    enum Key: LocalRecord.DatabaseKey {
        case native
        case translation
        case note
        case politeness
        case relations
        case alternatives
    }
    
    /// Vocabulary politeness value.
    /// - warning: These values should not be changed because they must be matched with the database.
    enum Politeness: LocalRecord.DatabaseIntegerEnum, CaseIterable {
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
}


extension Vocabulary {
    
    /// Add connection between the given vocabulary and create a connection object.
    /// - returns: The `VocabularyConnection` created.
    func addConnection(with vocabulary: Vocabulary, type: VocabularyConnection.ConnectionType) -> VocabularyConnection {
        switch type {
        case .related:
            self.relations.insert(vocabulary)
            vocabulary.relations.insert(self)
        case .alternative:
            self.alternatives.insert(vocabulary)
            vocabulary.alternatives.insert(self)
        case .unknown: ()
        }
        
        let connection = VocabularyConnection(type: type, source: self, target: vocabulary, context: managedObjectContext!)
        connections.insert(connection)
        return connection
    }
    
    /// Remove the connection between the given vocabulary and delete the connection object.
    /// - returns: The deleted `VocabularyConnection` if the connections was removed. Otherwise, `nil`.
    func removeConnection(with vocabulary: Vocabulary, type: VocabularyConnection.ConnectionType) -> VocabularyConnection? {
        guard let connection = connections.first(where: { $0.type == type && $0.isConnection(of: (self, vocabulary)) }) else { return nil }
        switch type {
        case .related:
            self.relations.remove(vocabulary)
            vocabulary.relations.remove(self)
            managedObjectContext?.delete(connection)
            return connection
        case .alternative:
            self.alternatives.remove(vocabulary)
            vocabulary.alternatives.remove(self)
            managedObjectContext?.delete(connection)
            return connection
        case .unknown:
            return nil
        }
    }
    
    @discardableResult
    func addTag(_ tag: Tag) -> Bool {
        guard tags.contains(tag) == false else { return false }
        tags.insert(tag)
        return true
    }
    
    @discardableResult
    func removeTag(_ tag: Tag) -> Bool {
        guard tags.contains(tag) else { return false }
        tags.remove(tag)
        return true
    }
}
