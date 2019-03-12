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
    @NSManaged private(set) var source: Vocabulary
    @NSManaged private(set) var target: Vocabulary
    @NSManaged private(set) var vocabularies: Set<Vocabulary>
    
    var type: ConnectionType {
        return ConnectionType(rawValue: connectionType) ?? .unknown
    }
    
    
    convenience init(type: ConnectionType, source: Vocabulary, target: Vocabulary, context: NSManagedObjectContext) {
        self.init(context: context)
        self.connectionType = type.rawValue
        self.source = source
        self.target = target
        self.vocabularies = [source, target]
        let recordName = "\(source.recordMetadata.recordName)+\(target.recordMetadata.recordName)"
        recordMetadata = RecordMetadata(recordType: recordType, recordName: recordName, zone: recordZone, context: context)
    }
    
    func isConnection(of vocabularies: (Vocabulary, Vocabulary)) -> Bool {
        return self.vocabularies.contains(vocabularies.0) && self.vocabularies.contains(vocabularies.1)
    }
}


extension VocabularyConnection {
    
    func recordValuesForServerKeys() -> [String : Any] {
        return [
            Key.connectionType.stringValue: connectionType,
            Key.sourceRecordName.stringValue: source.recordMetadata.recordName,
            Key.targetRecordName.stringValue: target.recordMetadata.recordName
        ]
    }
    
    enum Key: LocalRecord.ServerKey {
        case connectionType
        case sourceRecordName
        case targetRecordName
    }
    
    /// - warning: These values should not be changed because they must be matched with the database.
    enum ConnectionType: LocalRecord.ServerStringValue, CaseIterable {
        case unknown
        case related
        case alternative
    }
}


extension VocabularyConnection {
    
    /// Fetch `VocabularConnection` from the given context.
    /// - parameters:
    ///   - context: The context to fetch from.
    ///   - recordNames: The source and target vocabulary's record name. The order does not matter.
    static func fetch(from context: NSManagedObjectContext, type: VocabularyConnection.ConnectionType, vocabularies: (Vocabulary, Vocabulary)) -> VocabularyConnection? {
        let request: NSFetchRequest<VocabularyConnection> = VocabularyConnection.fetchRequest()
        let recordNameContains = "recordMetadata.recordName contains[c]"
        let format = "((source == %@ AND target == %@) OR (source == %@ AND target == %@)) AND connectionType == %@"
        request.predicate = NSPredicate(format: format, vocabularies.0, vocabularies.1, vocabularies.1, vocabularies.0, type.rawValue)
        let connections = try? context.fetch(request)
        return connections?.first
    }
}
