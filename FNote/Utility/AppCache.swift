//
//  AppCache.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation
import BDUIKnit


/// An object that provide access to application's values stored in `UserDefaults`.
enum AppCache {
    
    // MARK: Typealias
    
    typealias UbiquityIdentityToken = (NSCoding & NSCopying & NSObjectProtocol)
    

    // MARK: Notification Name
    
    static let nPublicUserDidChange = Notification.Name(rawValue: "kAppCache.nEncodedPublicUserDidChange")
    
    
    // MARK: UserDefaults
    
    @BDPersist(in: .userDefaults, key: "kAppCache.ubiquityIdentityToken", default: nil)
    static var ubiquityIdentityToken: UbiquityIdentityToken?
    
    @BDPersist(in: .userDefaults, key: "kAppCache.shouldShowOnboard", default: true)
    static var shouldShowOnboard: Bool
    
    @BDPersist(in: .userDefaults, key: "kAppCache.lastKnownVersion", default: nil)
    static var lastKnownVersion: String?
    
    @BDPersist(in: .userDefaults, key: "kAppCache.hasSetupUserUpdateCKSubscription", default: false)
    static var hasSetupUserUpdateCKSubscription: Bool
    
    @BDPersist(in: .userDefaults, key: "kAppCache.publicUserData", default: nil, post: nPublicUserDidChange)
    static var publicUserData: Data?
    
    
    // MARK: Ubiquitous
    
    @BDPersist(in: .ubiquitousStore, key: "kAppCache.currentCollectionUUID", default: nil)
    static var currentCollectionUUID: String?
}


extension AppCache {
    
    static func cachePublicUser(_ user: PublicUser) {
        guard let data = try? JSONEncoder().encode(user) else { return }
        publicUserData = data
    }
    
    static func publicUser() -> PublicUser? {
        guard let data = publicUserData else { return nil }
        let user = try? JSONDecoder().decode(PublicUser.self, from: data)
        return user
    }
}
