//
//  PublishedNoteCard.swift
//  FNote
//
//  Created by Dara Beng on 2/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


struct PublishedNoteCard {
    /// The collection the card belong to.
    let publishedCollectionID: String
    
    /// The CKRecord ID.
    let publishedID: String
    
    let native: String
    let translation: String
    let favorited: Bool
    let formality: Int
    let note: String
    let tags: [String]
    var relationships: [String]
}


extension PublishedNoteCard: PublishableRecord {
    
    static let ckRecordType = "PublishedNoteCard"
    static let kCollectionRef = "collectionRef"
    
    func ckRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: publishedID)
        let record = CKRecord(recordType: Self.ckRecordType, recordID: recordID)
        record["publishedCollectionID"] = publishedCollectionID
        record["publishedID"] = publishedID
        record["native"] = native
        record["translation"] = translation
        record["favorited"] = favorited
        record["formality"] = formality
        record["note"] = note
        record["tags"] = tags.isEmpty ? nil : tags
        record["relationships"] = relationships.isEmpty ? nil : relationships
        
        let collectionRID = CKRecord.ID(recordName: publishedCollectionID)
        let collectionRef = CKRecord.Reference(recordID: collectionRID, action: .deleteSelf)
        record[Self.kCollectionRef] = collectionRef
        
        return record
    }
}


extension PublishedNoteCard {
    
    init(record: CKRecord) {
        self.init(
            publishedCollectionID: record[""] as? String ?? "",
            publishedID: record[""] as? String ?? "",
            native: record[""] as? String ?? "",
            translation: record[""] as? String ?? "",
            favorited: record[""] as? Bool ?? false,
            formality: record[""] as? Int ?? 0,
            note: record[""] as? String ?? "",
            tags: record[""] as? [String] ?? [],
            relationships: record[""] as? [String] ?? []
        )
    }
}
