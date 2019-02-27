//
//  CloudKitService.swift
//  FNote
//
//  Created by Dara Beng on 1/22/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CloudKit


class CloudKitService {
    
    static let current = CloudKitService()
    

    let container = CKContainer.default()
    
    private(set) var accountStatus: CKAccountStatus = .couldNotDetermine
    
    
    // MARK: - Constructor
    
    private init() {}
    
    
    // MARK: - Function
    
    func checkAccountStatus() {
        container.accountStatus { (status, error) in
            self.accountStatus = error == nil ? status : .couldNotDetermine
        }
    }
}


extension CloudKitService {
    
    static let ckVocabularyCollectionZone = CKRecordZone(zoneName: "VocabularyCollectionZone")
    
    /// The account token indicated that there is no account.
    static var noAccountToken: String { return "00000-00000-00000-00000-00000" }
    
    /// The current account token. Return a `noAccountToken` if account is not available.
    static var accountToken: String {
        var token = FileManager.default.ubiquityIdentityToken?.description ?? noAccountToken
        token = token.trimmingCharacters(in: .symbols)
        token = token.replacingOccurrences(of: " ", with: "-")
        return token
    }
}
