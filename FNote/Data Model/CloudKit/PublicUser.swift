//
//  PublicUser.swift
//  FNote
//
//  Created by Dara Beng on 3/4/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


struct PublicUser: PublicRecord {
    
    let userID: String
    
    private(set) var record: CKRecord?
    
    let username: String
    
    let about: String
    
    
    init(userID: String, username: String, about: String) {
        self.userID = userID
        self.username = username
        self.about = about
    }
}


extension PublicUser {
    
    static let recordType = "PublicUser"
    
    var recordName: String {
        userID
    }
    
    enum RecordKeys: CodingKey {
        case userID
        case username
        case about
        case profileThumbnailAsset
        case profileImageAsset
    }
    
    func createCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: recordName)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        
        let keyedRecord = record.keyedRecord(keys: RecordKeys.self)
        keyedRecord[.userID] = userID
        keyedRecord[.username] = username
        keyedRecord[.about] = about
        
        return record
    }
    
    init(record: CKRecord) {
        guard record.recordType == Self.recordType else {
            fatalError("🧨 attempt to construct \(Self.self) with unmatched record type '\(record.recordType)' 🧨")
        }
        
        let keyedRecord = record.keyedRecord(keys: RecordKeys.self)
        userID = record.recordID.recordName
        self.record = record
        
        username = keyedRecord[.username] as? String ?? ""
        about = keyedRecord[.about] as? String ?? ""
    }
}
