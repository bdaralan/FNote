//
//  AppCache.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation
import BDSwiftility


/// An object that provide access to application's values stored in `UserDefaults`.
struct AppCache {
    
    // MARK: Typealias
    
    typealias UbiquityIdentityToken = (NSCoding & NSCopying & NSObjectProtocol)
    
    
    // MARK: Setup
    
    @BDStoredValue(in: .userDefaults, key: "kAppCache.ubiquityIdentityToken", default: nil)
    static var ubiquityIdentityToken: UbiquityIdentityToken?
    
    @BDStoredValue(in: .userDefaults, key: "kAppCache.currentCollectionUUID", default: nil)
    static var currentCollectionUUID: String?
    
    @BDStoredValue(in: .userDefaults, key: "kAppCache.shouldShowOnboard", default: true)
    static var shouldShowOnboard: Bool
    
    @BDStoredValue(in: .userDefaults, key: "kAppCache.lastKnownVersion", default: nil)
    static var lastKnownVersion: String?
    
    @BDStoredValue(in: .userDefaults, key: "kAppCache.hasSetupUserUpdateCKSubscription", default: false)
    static var hasSetupUserUpdateCKSubscription: Bool
    
    
    // MARK: Public User
    
    @BDStoredValue(in: .userDefaults, key: "kAppCache.publicUser", default: Data())
    static private var encodedPublicUser: Data
}


extension AppCache {
    
    static func cacheUser(_ user: PublicUser) {
        guard let data = try? JSONEncoder().encode(user) else { return }
        encodedPublicUser = data
    }
    
    static func cachedUser() -> PublicUser {
        do {
            let user = try JSONDecoder().decode(PublicUser.self, from: encodedPublicUser)
            return user
        } catch {
            print("⚠️ failed to encode PublicUser with error: \(error) ⚠️")
            return PublicUser(userID: "", username: "", about: "")
        }
    }
}
