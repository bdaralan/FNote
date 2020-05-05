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
    let tokenData: Data?
    
    
    init(senderID: String, receiverID: String, token: TokenType, tokenInfo: Data? = nil) {
        self.tokenID = Self.createTokenID(senderID: senderID, receiverID: receiverID, token: token)
        self.senderID = senderID
        self.receiverID = receiverID
        self.tokenType = token
        self.tokenData = tokenInfo
    }
    
    
    func report() -> Report? {
        guard tokenType == .report else { return nil }
        guard let data = tokenData else { return nil }
        guard let report = try? JSONDecoder().decode(Report.self, from: data) else { return nil }
        return report
    }
    
    
    /// Create a UUID by from MD5 hashed sender + receiver + token
    static func createTokenID(senderID: String, receiverID: String, token: TokenType) -> String {
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
    
    enum RecordFields: RecordField {
        case tokenID        // the hash of senderID + receiverID
        case senderID       // the user who send this token
        case receiverID     // the record the token belong to
        case tokenType      // the token type
        case tokenDataAsset // the token's info json
        case receiverRef    // the reference of the record being report
    }
    
    enum TokenType: Int {
        case unknown = 0
        case like
        case report
    }
    
    
    init(record: CKRecord) {
        guard record.recordType == Self.recordType else {
            fatalError("🧨 attempt to construct \(Self.self) with unmatched record type '\(record.recordType)' 🧨")
        }
        
        let modifier = RecordModifier<RecordFields>(record: record)
        tokenID = record.recordID.recordName
        
        senderID = modifier.string(for: .senderID)!
        receiverID = modifier.string(for: .receiverID)!
        tokenType = TokenType(rawValue: modifier.integer(for: .tokenType) ?? 0)!
        
        // TODO: check if CKAsset.fileURL is always local or remote
        let tokenDataAsset = modifier.asset(for: .tokenDataAsset)
        if let url = tokenDataAsset?.fileURL, let data = try? Data(contentsOf: url) {
            tokenData = data
        } else {
            tokenData = nil
        }
    }
    
    
    func createCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: tokenID)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        
        var modifier = RecordModifier<RecordFields>(record: record)
        modifier[.tokenID] = tokenID
        modifier[.senderID] = senderID
        modifier[.receiverID] = receiverID
        modifier[.tokenType] = tokenType.rawValue
        
        let receiverRID = CKRecord.ID(recordName: receiverID)
        let receiverRef = CKRecord.Reference(recordID: receiverRID, action: .deleteSelf)
        modifier[.receiverRef] = receiverRef
        
        // set token data if any
        guard let tokenData = tokenData else { return record }
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempUrl = tempDirectory.appendingPathComponent("\(tokenID).json")
        
        do {
            try tokenData.write(to: tempUrl)
            let tokenDataAsset = CKAsset(fileURL: tempUrl)
            modifier[.tokenDataAsset] = tokenDataAsset
        } catch {
            print("⚠️ unable to set token data asset to record \(Self.recordType) \(tokenID) ⚠️")
        }
        
        return record
    }
}


// MARK: - Token Data Object

extension PublicRecordToken {
    
    struct Report: Codable {
        
        let reason: String
    }
}
