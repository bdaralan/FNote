//
//  PublicUser.swift
//  FNote
//
//  Created by Dara Beng on 3/4/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


struct PublicUser: CloudKitRecord {
    
    let userID: String
    
    let username: String
    
    let about: String
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
        let keyedRecord = record.keyedRecord(keys: RecordKeys.self)
        userID = record.recordID.recordName
        username = keyedRecord[.username] as! String
        about = keyedRecord[.about] as? String ?? ""
    }
}
