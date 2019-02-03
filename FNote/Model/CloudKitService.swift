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
    
    private(set) var accountStatus: CKAccountStatus = .couldNotDetermine
    private(set) var userRecordIDName: String = "NoAccountUser" {
        didSet { NotificationCenter.default.post(name: CloudKitService.nUserRecordIDNameDidChange, object: userRecordIDName) }
    }
    
    let container = CKContainer.default()
    
    private init() {}
    
    func checkAccountStatus() {
        container.accountStatus { (status, error) in
            guard error == nil else {
                #warning("TODO: handle cloud kit error")
                fatalError("failed to check account status")
            }
            self.accountStatus = status
        }
    }
    
    func checkAccountID() {
        container.fetchUserRecordID { (userRecordID, error) in
            guard let userRecordID = userRecordID else {
                #warning("TODO: handle cloud kit error")
                // TODO: set userRecordIDName to some default name that allow to user the app
                // but diable all saving features
                fatalError("failed to fetch user record id")
            }
            self.userRecordIDName = userRecordID.recordName
        }
    }
}


extension CloudKitService {
    
    static let nUserRecordIDNameDidChange = Notification.Name(rawValue: "CloudKitService.nUserRecordIDNameDidChange")
    
    static let ckVocabularyCollectionZone = CKRecordZone(zoneName: "VocabularyCollectionZone")
}
