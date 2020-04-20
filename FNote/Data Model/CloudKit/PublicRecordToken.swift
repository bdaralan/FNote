//
//  PublicRecordToken.swift
//  FNote
//
//  Created by Dara Beng on 4/19/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit
import CryptoKit


struct PublicRecordToken: PublicRecord {
    
    private(set) var record: CKRecord?
    
    /// The token CKRecord ID.
    let tokenID: String
    
    /// The sender CKRecord ID.
    let senderID: String
    
    /// The CKRecord's ID that the token belong to.
    let receiverID: String
    
    /// The type of token.
    let tokenType: TokenType
    
    /// The encoded token's info.
    let tokenInfo: Data?
    
    
    init(tokenID: String, senderID: String, receiverID: String, tokenType: TokenType, tokenInfo: Data? = nil) {
        self.tokenID = Self.createTokenID(for: tokenType, senderID: senderID, receiverID: receiverID)
        self.senderID = senderID
        self.receiverID = receiverID
        self.tokenType = tokenType
        self.tokenInfo = tokenInfo
    }
    
    /// Create a UUID by from MD5 hashed sender + receiver + token
    static func createTokenID(for token: TokenType, senderID: String, receiverID: String) -> String {
        let combinedString = "\(senderID)\(receiverID)\(token.rawValue)".data(using: .utf8)!
        let hashedString = Insecure.MD5.hash(data: combinedString)
        var tokenID = hashedString.compactMap { String(format: "%02x", $0) }.joined()
        for hyphenIndex in [8, 13, 18, 23] {
            let startIndex = tokenID.startIndex
            let insertIndex = tokenID.index(startIndex, offsetBy: hyphenIndex)
            tokenID.insert("-", at: insertIndex)
        }
        return UUID(uuidString: tokenID)!.uuidString
    }
}


extension PublicRecordToken {
    
    static let recordType = "PublicRecordToken"
    
    var recordName: String {
        tokenID
    }
    
    func createCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: tokenID)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        
        let keyedRecord = KeyedRecord<RecordKeys>(record: record)
        keyedRecord[.tokenID] = tokenID
        keyedRecord[.senderID] = senderID
        keyedRecord[.receiverID] = receiverID
        keyedRecord[.tokenType] = tokenType.rawValue
        keyedRecord[.tokenData] = tokenInfo
        
        let receiverRID = CKRecord.ID(recordName: receiverID)
        let receiverRef = CKRecord.Reference(recordID: receiverRID, action: .deleteSelf)
        keyedRecord[.receiverRef] = receiverRef
        
        return record
    }
    
    init(record: CKRecord) {
        guard record.recordType == Self.recordType else {
            fatalError("🧨 attempt to construct \(Self.self) with unmatched record type '\(record.recordType)' 🧨")
        }
        
        let keyedRecord = KeyedRecord<RecordKeys>(record: record)
        tokenID = record.recordID.recordName
        
        senderID = keyedRecord[.senderID] as! String
        receiverID = keyedRecord[.receiverID] as! String
        tokenType = TokenType(rawValue: keyedRecord[.tokenType] as! Int)!
        tokenInfo = keyedRecord[.tokenData] as? Data
    }
    
    enum RecordKeys: CodingKey {
        case tokenID
        case senderID
        case receiverID
        case tokenType
        case tokenData
        case receiverRef
    }
    
    enum TokenType: Int {
        case like
        case report
    }
}



