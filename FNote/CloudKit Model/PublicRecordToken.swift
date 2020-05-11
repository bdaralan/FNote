//
//  PublicRecordToken.swift
//  FNote
//
//  Created by Dara Beng on 4/19/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit
import CryptoKit


/// A token of a record.
///
/// This object must be as small as possible for performance reason.
///
/// Generally, it should contain only an integer token type and a small encoded object.
///
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
    
    
    init(senderID: String, receiverID: String, token: TokenType, tokenInfo: Data? = nil) {
        self.tokenID = Self.createTokenID(senderID: senderID, receiverID: receiverID, token: token)
        self.senderID = senderID
        self.receiverID = receiverID
        self.tokenType = token
        self.tokenInfo = tokenInfo
    }
    
    
    func report() -> Report? {
        guard tokenType == .report else { return nil }
        guard let data = tokenInfo else { return nil }
        guard let report = try? JSONDecoder().decode(Report.self, from: data) else { return nil }
        return report
    }
    
    
    /// Create a UUID by from MD5 hashed sender + receiver + token
    static func createTokenID(senderID: String, receiverID: String, token: TokenType) -> String {
        let combinedString = "\(senderID)\(receiverID)\(token.rawValue)".data(using: .utf8)!
        let hashedString = Insecure.MD5.hash(data: combinedString)
        var tokenID = hashedString.compactMap { String(format: "%02x", $0) }.joined()
        for hyphenIndex in [8, 13, 18, 23] { // the indexes to hyphenate
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
    
    enum RecordFields: RecordField {
        case tokenID        // the hash of senderID + receiverID
        case senderID       // the user who send this token
        case receiverID     // the record the token belong to
        case tokenType      // the token type
        case tokenInfo      // the token's info json
        case receiverRef    // the reference of the record being report
    }
    
    enum TokenType: Int {
        case unspecified = 0
        case like
        case report
    }
    
    
    init(record: CKRecord) {
        guard record.recordType == Self.recordType else {
            fatalError("🧨 attempt to construct \(Self.self) with unmatched record type '\(record.recordType)' 🧨")
        }
        
        self.record = record
        
        let modifier = RecordModifier<RecordFields>(record: record)
        tokenID = record.recordID.recordName
        
        senderID = modifier.string(for: .senderID)!
        receiverID = modifier.string(for: .receiverID)!
        tokenType = TokenType(rawValue: modifier.integer(for: .tokenType) ?? 0)!
        tokenInfo = modifier.data(for: .tokenInfo)
    }
    
    
    func createCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: tokenID)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        
        var modifier = RecordModifier<RecordFields>(record: record)
        modifier[.tokenID] = tokenID
        modifier[.senderID] = senderID
        modifier[.receiverID] = receiverID
        modifier[.tokenType] = tokenType.rawValue
        modifier[.tokenInfo] = tokenInfo
        
        modifier.setCascadeDelete(referenceID: receiverID, field: .receiverRef)
        
        return record
    }
}


// MARK: - Token Data Object

extension PublicRecordToken {
    
    struct Report: Codable {
        
        let reason: String
    }
}
