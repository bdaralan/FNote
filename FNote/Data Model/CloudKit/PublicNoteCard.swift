//
//  PublicNoteCard.swift
//  FNote
//
//  Created by Dara Beng on 2/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


struct PublicNoteCard {
    
    /// The CKRecord ID of the card's collection.
    let collectionID: String
    
    /// The CKRecord ID.
    let cardID: String
    
    var native: String
    var translation: String
    var favorited: Bool
    var formality: Int
    var note: String
    var tags: [String]
    
    // The CKRecord IDs of the related cards.
    var relationships: [String]
}


extension PublicNoteCard: CloudKitRecord {
    
    static let recordType = "PublicNoteCard"
    
    var recordName: String {
        cardID
    }
    
    enum RecordKeys: CodingKey {
        case collectionID
        case cardID
        case native
        case translation
        case favorited
        case formality
        case note
        case tags
        case relationships
        case collectionRef
    }
    
    func createCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: recordName)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        
        let keyedRecord = record.keyedRecord(keys: RecordKeys.self)
        keyedRecord[.collectionID] = collectionID
        keyedRecord[.cardID] = cardID
        keyedRecord[.native] = native
        keyedRecord[.translation] = translation
        keyedRecord[.favorited] = favorited
        keyedRecord[.formality] = formality
        keyedRecord[.note] = note
        keyedRecord[.tags] = tags.joined(separator: ",")
        keyedRecord[.relationships] = relationships.isEmpty ? nil : relationships
        
        let collectionRecID = CKRecord.ID(recordName: collectionID)
        let collectionRef = CKRecord.Reference(recordID: collectionRecID, action: .deleteSelf)
        keyedRecord[.collectionRef] = collectionRef
        
        return record
    }
}


extension PublicNoteCard {
    
    init(record: CKRecord) {
        guard record.recordType == Self.recordType else {
            fatalError("🧨 attempt to construct \(Self.self) with unmatched record type '\(record.recordType)' 🧨")
        }
        
        let keyedRecord = record.keyedRecord(keys: RecordKeys.self)
        cardID = record.recordID.recordName
        
        collectionID = keyedRecord[.collectionID] as? String ?? ""
        native = keyedRecord[.native] as? String ?? ""
        translation = keyedRecord[.translation] as? String ?? ""
        favorited = keyedRecord[.favorited] as? Bool ?? false
        formality = keyedRecord[.formality] as? Int ?? 0
        note = keyedRecord[.note] as? String ?? ""
        tags = (keyedRecord[.tags] as? String)?.components(separatedBy: ",") ?? []
        relationships = keyedRecord[.relationships] as? [String] ?? []
    }
}
