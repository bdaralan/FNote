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
    

    // MARK: Key
    enum Keys: BDPersistKey {
        var prefix: String { "kAppCache." }
        case ubiquityIdentityToken
        case shouldShowOnboard
        case lastKnownVersion
        case hasSetupUserUpdateCKSubscription
        case publicUserData
        case currentCollectionUUID
    }
    
    
    // MARK: Notification Name
    
    static let nPublicUserDidChange = Notification.Name(rawValue: Keys.publicUserData.prefixedKey)
    
    static let nCurrentCollectionDidChange = Notification.Name(rawValue: Keys.currentCollectionUUID.prefixedKey)
    
    
    // MARK: UserDefaults
    
    @BDPersist(in: .userDefaults, key: Keys.ubiquityIdentityToken, default: nil)
    static var ubiquityIdentityToken: UbiquityIdentityToken?
    
    @BDPersist(in: .userDefaults, key: Keys.shouldShowOnboard, default: true)
    static var shouldShowOnboard: Bool
    
    @BDPersist(in: .userDefaults, key: Keys.lastKnownVersion, default: nil)
    static var lastKnownVersion: String?
    
    @BDPersist(in: .userDefaults, key: Keys.hasSetupUserUpdateCKSubscription, default: false)
    static var hasSetupUserUpdateCKSubscription: Bool
    
    @BDPersist(in: .userDefaults, key: Keys.publicUserData, default: nil, post: nPublicUserDidChange)
    static var publicUserData: Data?
    
    
    // MARK: Ubiquitous
    
    @BDPersist(in: .ubiquitousStore, key: Keys.currentCollectionUUID, default: nil, post: nCurrentCollectionDidChange)
    static var currentCollectionUUID: String?
    
    
    // MARK: Method
    
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
