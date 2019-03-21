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
        get { return ConnectionType(rawValue: Int(connectionTypeValue)) ?? .unknown }
    }
    
    
    convenience init(type: ConnectionType, source: Vocabulary, target: Vocabulary, context: NSManagedObjectContext) {
        self.init(context: context)
        self.type = type
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
    enum ConnectionType: LocalRecord.DatabaseIntegerEnum, CaseIterable {
        case unknown
        case related
        case alternative
    }
}


extension VocabularyConnection {
    
    /// Fetch `VocabularConnection` from the given context.
    /// - parameters:
    ///   - context: The context to fetch from.
    ///   - type: The connection type.
    ///   - vocabularies: The source and target of the connection.
    /// - returns: Array of matched connections or empty.
    static func fetch(from context: NSManagedObjectContext, type: VocabularyConnection.ConnectionType, vocabularies: (Vocabulary, Vocabulary)) -> [VocabularyConnection] {
        let request: NSFetchRequest<VocabularyConnection> = VocabularyConnection.fetchRequest()
        let format = "connectionType == %@ AND vocabularies contains[c] AND vocabularies contains[c]"
        request.predicate = NSPredicate(format: format, vocabularies.0, vocabularies.1, type.rawValue)
        let connections = try? context.fetch(request)
        return connections ?? []
    }
}


extension VocabularyConnection {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<VocabularyConnection> {
        return NSFetchRequest<VocabularyConnection>(entityName: "VocabularyConnection")
    }
    
    @objc(addVocabulariesObject:)
    @NSManaged private func addToVocabularies(_ value: Vocabulary)
    
    @objc(removeVocabulariesObject:)
    @NSManaged private func removeFromVocabularies(_ value: Vocabulary)
    
    @objc(addVocabularies:)
    @NSManaged private func addToVocabularies(_ values: NSSet)
    
    @objc(removeVocabularies:)
    @NSManaged private func removeFromVocabularies(_ values: NSSet)
}
