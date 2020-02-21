//
//  PublishedCollection.swift
//  FNote
//
//  Created by Dara Beng on 2/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


protocol PublishableRecord {
    
    static var ckRecordType: CKRecord.RecordType { get }
    
    func ckRecord() -> CKRecord
}


struct PublishedCollection {
    
    /// The CKRecord ID.
    let publishedID: String
    
    /// The published date.
    let publishedDate: Date
    
    /// The author publishing ID.
    let authorID: String
    
    /// The author name.
    let author: String
    
    /// The name of the published collection.
    let name: String
    
    /// A short description of the published collection.
    let description: String
    
    /// The languages used in the collection.
    /// Usually two, native and translation.
    let languages: [String]
    
    /// The tags describing the collection.
    let tags: [String]
}


extension PublishedCollection: PublishableRecord {
    
    static let ckRecordType = "PublishedCollection"
    
    func ckRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: publishedID)
        let record = CKRecord(recordType: Self.ckRecordType, recordID: recordID)
        record["publishedID"] = publishedID
        record["publishedDate"] = publishedDate
        record["authorID"] = authorID
        record["author"] = author
        record["name"] = name
        record["description"] = description
        record["languages"] = languages
        record["tags"] = tags
        return record
    }
}


