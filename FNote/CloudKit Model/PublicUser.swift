//
//  PublicUser.swift
//  FNote
//
//  Created by Dara Beng on 3/4/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


struct PublicUser: PublicRecord, Codable {
    
    private(set) var record: CKRecord?
    
    let userID: String
    
    let username: String
    
    let about: String
    
    
    init(userID: String, username: String, about: String) {
        self.userID = userID
        self.username = username
        self.about = about
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RecordFields.self)
        userID = try container.decode(String.self, forKey: .userID)
        username = try container.decode(String.self, forKey: .username)
        about = try container.decode(String.self, forKey: .about)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RecordFields.self)
        try container.encode(userID, forKey: .userID)
        try container.encode(username, forKey: .username)
        try container.encode(about, forKey: .about)
    }
}


extension PublicUser {
    
    static let recordType = "PublicUser"
    
    var recordName: String {
        userID
    }
    
    enum RecordFields: RecordField {
        case userID
        case username
        case about
        case profileThumbnailAsset
        case profileImageAsset
        
        case lowercasedUsername
    }
    
    
    init(record: CKRecord) {
        guard record.recordType == Self.recordType else {
            fatalError("🧨 attempt to construct \(Self.self) with unmatched record type '\(record.recordType)' 🧨")
        }
        
        self.record = record
        
        let modifier = RecordModifier<RecordFields>(record: record)
        userID = record.recordID.recordName
        
        username = modifier.string(for: .username) ?? ""
        about = modifier.string(for: .about) ?? ""
    }
    
    
    func createCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: recordName)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        
        var modifier = RecordModifier<RecordFields>(record: record)
        modifier[.userID] = userID
        modifier[.username] = username
        modifier[.about] = about
        modifier[.lowercasedUsername] = username.lowercased()
        
        return record
    }
    
    /// Get the public ID from CloudKit record ID.
    /// - Parameter recordID: User CloudKit record ID.
    /// - Returns: The public ID version.
    static func publicID(from recordID: CKRecord.ID) -> String {
        recordID.recordName.replacingOccurrences(of: "_", with: "")
    }
}
