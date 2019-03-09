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
    @NSManaged private(set) var connectionType: String
    @NSManaged private(set) var sourceRecordName: String
    @NSManaged private(set) var targetRecordName: String
    
    var type: ConnectionType { return ConnectionType(rawValue: connectionType)! }
    
    
    convenience init(type: ConnectionType, sourceRecordName: String, targetRecordName: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.connectionType = type.rawValue
        self.sourceRecordName = sourceRecordName
        self.targetRecordName = targetRecordName
        let recordName = "\(sourceRecordName)+\(targetRecordName)"
        recordMetadata = RecordMetadata(recordType: recordType, recordName: recordName, zone: recordZone, context: context)
    }
    
    func recordValuesForServerKeys() -> [String : Any] {
        return [
            Key.connectionType.stringValue: connectionType,
            Key.sourceRecordName.stringValue: sourceRecordName,
            Key.targetRecordName.stringValue: targetRecordName
        ]
    }
    
    enum Key: LocalRecord.ServerKey {
        case connectionType
        case sourceRecordName
        case targetRecordName
    }
    
    enum ConnectionType: String, CaseIterable {
        case related
        case alternative
    }
}


extension VocabularyConnection {
    
    static func predicate(recordNames: (String, String)) -> NSPredicate {
        let format = "connectionName contains[c] %@ AND connectionName contains[c] %@"
        return NSPredicate(format: format, recordNames.0, recordNames.1)
    }
}
