//
//  PublicCollection.swift
//  FNote
//
//  Created by Dara Beng on 2/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


struct PublicCollection {
    
    /// The CKRecord ID.
    let collectionID: String
    
    /// The author's userID.
    let authorID: String
    
    /// The name of the published collection.
    let name: String
    
    /// A short description describing the collection.
    let description: String
    
    /// The native language used in the collection
    let primaryLanguage: String
    
    /// The translation language used in the collection
    let secondaryLanguage: String
    
    /// The tags describing the collection.
    /// - Note: A comma separated values
    let tags: [String]
    
    /// The number of cards.
    let cardsCount: Int
}


// MARK: - Database Record

extension PublicCollection: CloudKitRecord {
    
    static let recordType = "PublicCollection"
    
    var recordName: String {
        collectionID
    }
    
    enum RecordKeys: CodingKey {
        case collectionID
        case authorID
        case name
        case description
        case primaryLanguage
        case secondaryLanguage
        case tags
        case cardsCount
    }
    
    func createCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: recordName)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        
        let keyedRecord = record.keyedRecord(keys: RecordKeys.self)
        keyedRecord[.collectionID] = collectionID
        keyedRecord[.authorID] = authorID
        keyedRecord[.name] = name
        keyedRecord[.description] = description
        keyedRecord[.primaryLanguage] = primaryLanguage
        keyedRecord[.secondaryLanguage] = secondaryLanguage
        keyedRecord[.tags] = tags.isEmpty ? nil : tags
        keyedRecord[.cardsCount] = cardsCount
        
        return record
    }
    
    init(record: CKRecord) {
        let keyedRecord = record.keyedRecord(keys: RecordKeys.self)
        collectionID = record.recordID.recordName
        
        authorID = keyedRecord[.authorID] as? String ?? ""
        name = keyedRecord[.name] as? String ?? ""
        description = keyedRecord[.description] as? String ?? ""
        primaryLanguage = keyedRecord[.primaryLanguage] as? String ?? ""
        secondaryLanguage = keyedRecord[.secondaryLanguage] as? String ?? ""
        tags = keyedRecord[.tags] as? [String] ?? []
        cardsCount = keyedRecord[.cardsCount] as? Int ?? 0
    }
}
