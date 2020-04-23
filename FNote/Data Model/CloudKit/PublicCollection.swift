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

extension PublicCollection: PublicRecord {
    
    static let recordType = "PublicCollection"
    
    var recordName: String {
        collectionID
    }
    
    enum RecordFields: RecordField {
        case collectionID
        case authorID
        case name
        case description
        case primaryLanguage
        case secondaryLanguage
        case tags
        case cardsCount
    }
    
    
    init(record: CKRecord) {
        guard record.recordType == Self.recordType else {
            fatalError("🧨 attempt to construct \(Self.self) with unmatched record type '\(record.recordType)' 🧨")
        }
        
        let modifier = RecordModifier<RecordFields>(record: record)
        collectionID = record.recordID.recordName
        
        authorID = modifier[.authorID] as? String ?? ""
        name = modifier[.name] as? String ?? ""
        description = modifier[.description] as? String ?? ""
        primaryLanguage = modifier[.primaryLanguage] as? String ?? ""
        secondaryLanguage = modifier[.secondaryLanguage] as? String ?? ""
        tags = (modifier[.tags] as? String)?.components(separatedBy: ",") ?? []
        cardsCount = modifier[.cardsCount] as? Int ?? 0
    }
    
    
    func createCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: recordName)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        
        var modifier = RecordModifier<RecordFields>(record: record)
        modifier[.collectionID] = collectionID
        modifier[.authorID] = authorID
        modifier[.name] = name
        modifier[.description] = description
        modifier[.primaryLanguage] = primaryLanguage
        modifier[.secondaryLanguage] = secondaryLanguage
        modifier[.tags] = tags.joined(separator: ",")
        modifier[.cardsCount] = cardsCount
        
        return record
    }
}
