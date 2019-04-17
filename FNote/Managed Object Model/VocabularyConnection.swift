//
//  VocabularyConnection+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 3/8/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit


public class VocabularyConnection: NSManagedObject, LocalRecord {
    
    var recordType: CKRecord.RecordType { return "VocabularyConnection" }
    var recordZone: CKRecordZone { return CloudKitService.ckVocabularyCollectionZone }

    @NSManaged private(set) var recordMetadata: RecordMetadata
    @NSManaged private var connectionTypeValue: Int64
    @NSManaged private(set) var source: Vocabulary
    @NSManaged private(set) var target: Vocabulary
    @NSManaged private(set) var vocabularies: Set<Vocabulary>
    
    var type: ConnectionType {
        set { connectionTypeValue = Int64(newValue.rawValue) }
        get { return ConnectionType(rawValue: Int(connectionTypeValue))! }
    }
    
    
    convenience init(type: ConnectionType, source: Vocabulary, target: Vocabulary) {
        let context = source.managedObjectContext!
        self.init(context: context)
        self.type = type
        self.source = source
        self.target = target
        self.vocabularies = [source, target]
        let recordName = "\(source.recordMetadata.recordName)+\(target.recordMetadata.recordName)=\(type.rawValue)"
        recordMetadata = RecordMetadata(recordType: recordType, recordName: recordName, zone: recordZone, context: context)
    }
    
    
    /// Check if the connection is a connection of the given vocabularies.
    func isConnection(of v1: Vocabulary, and v2: Vocabulary) -> Bool {
        return vocabularies.contains(v1) && vocabularies.contains(v2)
    }
}


extension VocabularyConnection {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<VocabularyConnection> {
        return NSFetchRequest<VocabularyConnection>(entityName: "VocabularyConnection")
    }
    
    func recordValuesForServerKeys() -> [String : Any] {
        return [
            Key.connectionType.stringValue: connectionTypeValue,
            Key.sourceRecordName.stringValue: source.recordMetadata.recordName,
            Key.targetRecordName.stringValue: target.recordMetadata.recordName
        ]
    }
    
    enum Key: LocalRecord.DatabaseKey {
        case connectionType
        case sourceRecordName
        case targetRecordName
    }
    
    /// - warning: These values should not be changed because they must be matched with the database.
    enum ConnectionType: LocalRecord.DatabaseIntegerEnum, CaseIterable, TextDisplayable {
        case related
        case alternative
        
        var displayText: String {
            switch self {
            case .alternative: return "Alternative"
            case .related: return "Related"
            }
        }
    }
}
