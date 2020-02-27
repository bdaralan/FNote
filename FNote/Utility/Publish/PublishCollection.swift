//
//  PublishCollection.swift
//  FNote
//
//  Created by Dara Beng on 2/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


struct PublishCollection {
    
    /// The CKRecord ID.
    let publishedID: String
    
    /// The published date.
    let publishedDate: Date
    
    /// The author's userID.
    let authorID: String
    
    /// The author name.
    let author: String
    
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
}


// MARK: - Database Record

extension PublishCollection: DatabaseRecord {
    
    static let recordType = "PublishedCollection"
    
    var recordName: String {
        publishedID
    }
    
    enum RecordKeys: CodingKey {
        case publishedID
        case publishedDate // ISO 8061 String Format
        case authorID
        case author
        case name
        case description
        case primaryLanguage
        case secondaryLanguage
        case tags
    }
    
    func createCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: recordName)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        
        let keyedRecord = KeyedRecord<RecordKeys>(record: record)
        keyedRecord[.publishedID] = publishedID
        keyedRecord[.publishedDate] = publishedDate.databaseDateString
        keyedRecord[.authorID] = authorID
        keyedRecord[.author] = author
        keyedRecord[.name] = name
        keyedRecord[.description] = description
        keyedRecord[.primaryLanguage] = primaryLanguage
        keyedRecord[.secondaryLanguage] = secondaryLanguage
        keyedRecord[.tags] = tags.sorted().joined(separator: ",")
        
        return record
    }
    
    init(record: CKRecord) {
        let keyedRecord = KeyedRecord<RecordKeys>(record: record)
        publishedID = keyedRecord[.publishedID] as! String
        publishedDate = Date.databaseDate(from: keyedRecord[.publishedDate] as! String)!
        authorID = keyedRecord[.authorID] as! String
        author = keyedRecord[.author] as! String
        name = keyedRecord[.name] as! String
        description = keyedRecord[.description] as! String
        primaryLanguage = keyedRecord[.primaryLanguage] as! String
        secondaryLanguage = keyedRecord[.secondaryLanguage] as! String
        tags = (keyedRecord[.tags] as! String).components(separatedBy: ",")
    }
}
