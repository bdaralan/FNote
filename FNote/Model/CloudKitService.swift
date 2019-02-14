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
    
    /// Current user's iCloud token.
    /// - note: A notification, `CloudKitService.nameUserAccountTokenDidChange`, is posted when this value is changed.
    private(set) var iCloudToken: String {
        didSet {
            UserDefaults.standard.updateValue(iCloudToken, forKey: .cachedAccountToken)
            NotificationCenter.default.post(name: CloudKitService.nameUserAccountTokenDidChange, object: iCloudToken)
        }
    }
    
    // MARK: - Constructor
    
    private init() {
        iCloudToken = CloudKitService.currentAccountToken
    }
    
    
    // MARK: - Function
    
    func checkAccountStatus() {
        container.accountStatus { (status, error) in
            guard error == nil else {
                self.accountStatus = .couldNotDetermine
                self.iCloudToken = CloudKitService.noAccountToken
                return
            }
            self.accountStatus = status
            self.iCloudToken = CloudKitService.currentAccountToken
        }
    }
    
    func setupUserAccountChangedNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleAccountChanged), name: .CKAccountChanged, object: nil)
    }
    
    @objc private func handleAccountChanged() {
        checkAccountStatus()
    }
}


extension CloudKitService {
    
    static let nameUserAccountTokenDidChange = Notification.Name(rawValue: "CloudKitService.nameUserAccountTokenDidChange")
    
    static let ckVocabularyCollectionZone = CKRecordZone(zoneName: "VocabularyCollectionZone")
    
    static var noAccountToken: String { return "0000000000000000000000000" }
    
    static var cachedAccountToken: String {
        let key = "cachedAccountToken"
        let token = UserDefaults.standard.string(forKey: key) ?? noAccountToken
        UserDefaults.standard.setValue(token, forKey: key)
        return token
    }
    
    static var currentAccountToken: String {
        var token = FileManager.default.ubiquityIdentityToken?.description ?? noAccountToken
        token = token.trimmingCharacters(in: .symbols)
        token = token.replacingOccurrences(of: " ", with: "")
        return token
    }
}
