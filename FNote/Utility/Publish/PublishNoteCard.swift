//
//  PublishNoteCard.swift
//  FNote
//
//  Created by Dara Beng on 2/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


struct PublishNoteCard {
    
    /// The CKRecord ID of the card's collection.
    let publishedCollectionID: String
    
    /// The CKRecord ID.
    let publishedID: String
    
    var native: String
    var translation: String
    var favorited: Bool
    var formality: Int
    var note: String
    var tags: [String]
    
    // The CKRecord IDs of the related cards.
    var relationships: [String]
}


extension PublishNoteCard: DatabaseRecord {
    
    static let recordType = "PublishedNoteCard"
    
    var recordName: String {
        publishedID
    }
    
    enum RecordKeys: CodingKey {
        case publishedCollectionID
        case publishedID
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
        
        let keyedRecord = KeyedRecord<RecordKeys>(record: record)
        keyedRecord[.publishedCollectionID] = publishedCollectionID
        keyedRecord[.publishedID] = publishedID
        keyedRecord[.native] = native
        keyedRecord[.translation] = translation
        keyedRecord[.favorited] = favorited
        keyedRecord[.formality] = formality
        keyedRecord[.note] = note
        keyedRecord[.tags] = tags.joined(separator: ",")
        keyedRecord[.relationships] = relationships.isEmpty ? nil : relationships
        
        let collectionID = CKRecord.ID(recordName: publishedCollectionID)
        let collectionRef = CKRecord.Reference(recordID: collectionID, action: .deleteSelf)
        keyedRecord[.collectionRef] = collectionRef
        
        return record
    }
}


extension PublishNoteCard {
    
    init(record: CKRecord) {
        let keyedRecord = KeyedRecord<RecordKeys>(record: record)
        publishedCollectionID = keyedRecord[.publishedCollectionID] as! String
        publishedID = keyedRecord[.publishedID] as! String
        
        native = keyedRecord[.native] as? String ?? ""
        translation = keyedRecord[.translation] as? String ?? ""
        favorited = keyedRecord[.favorited] as? Bool ?? false
        formality = keyedRecord[.formality] as? Int ?? 0
        note = keyedRecord[.note] as? String ?? ""
        tags = (keyedRecord[.tags] as? String ?? "").components(separatedBy: ",")
        relationships = keyedRecord[.relationships] as? [String] ?? []
    }
}
