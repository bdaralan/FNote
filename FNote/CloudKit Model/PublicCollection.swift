//
//  PublicCollection.swift
//  FNote
//
//  Created by Dara Beng on 2/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


struct PublicCollection: PublicRecord {
    
    private(set) var record: CKRecord? = nil
    
    /// The CKRecord ID.
    let collectionID: String
    
    /// The author's userID.
    let authorID: String
    
    /// The author's name.
    ///
    /// Possible to get outdated.
    /// Use authorID to fetch from the database if needed.
    let authorName: String
    
    /// The name of the published collection.
    let name: String
    
    /// A short description describing the collection.
    let description: String
    
    /// The native language code (ISO 639) in the collection.
    let primaryLanguageCode: String
    
    /// The translation language code (ISO 639) used in the collection.
    let secondaryLanguageCode: String
    
    /// The tags describing the collection.
    let tags: [String]
    
    /// The number of cards.
    let cardsCount: Int
    
    var localVoted = false
    
    
    var primaryLanguage: Language {
        Language(code: primaryLanguageCode)
    }
    
    var secondaryLanguage: Language {
        Language(code: secondaryLanguageCode)
    }
}


// MARK: - Database Record

extension PublicCollection {
    
    static let recordType = "PublicCollection"
    
    var recordName: String {
        collectionID
    }
    
    enum RecordFields: RecordField {
        case collectionID
        case authorID
        case authorName
        case name
        case description
        case primaryLanguageCode
        case secondaryLanguageCode
        case tags
        case cardsCount
    }
    
    
    init(record: CKRecord) {
        guard record.recordType == Self.recordType else {
            fatalError("🧨 attempt to construct \(Self.self) with unmatched record type '\(record.recordType)' 🧨")
        }
        
        self.record = record
        
        let modifier = RecordModifier<RecordFields>(record: record)
        collectionID = record.recordID.recordName
        
        authorID = modifier.string(for: .authorID) ?? ""
        authorName = modifier.string(for: .authorName) ?? ""
        name = modifier.string(for: .name) ?? ""
        description = modifier.string(for: .description) ?? ""
        primaryLanguageCode = modifier.string(for: .primaryLanguageCode) ?? ""
        secondaryLanguageCode = modifier.string(for: .secondaryLanguageCode) ?? ""
        cardsCount = modifier.integer(for: .cardsCount) ?? 0
        
        let formatter = PublicRecordFormatter()
        let recordTags = modifier.string(for: .tags) ?? ""
        tags = formatter.localTags(fromDatabaseTags: recordTags)
    }
    
    
    func createCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: recordName)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        
        var modifier = RecordModifier<RecordFields>(record: record)
        modifier[.collectionID] = collectionID
        modifier[.authorID] = authorID
        modifier[.authorName] = authorName
        modifier[.name] = name
        modifier[.description] = description
        modifier[.primaryLanguageCode] = primaryLanguageCode
        modifier[.secondaryLanguageCode] = secondaryLanguageCode
        modifier[.tags] = PublicRecordFormatter().databaseTags(fromLocalTags: tags)
        modifier[.cardsCount] = cardsCount
        
        return record
    }
}


extension PublicCollection {
    
    static func placeholder(collectionID: String = UUID().uuidString) -> PublicCollection {
        PublicCollection(
            collectionID: collectionID,
            authorID: "----", authorName: "----",
            name: "---------", description: "----",
            primaryLanguageCode: "---", secondaryLanguageCode: "---",
            tags: [], cardsCount: 0
        )
    }
}
