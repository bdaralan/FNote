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
    
    @BDStoredValue(in: .userDefaults, key: "kAppCache.hasSetupCKSubscriptions", default: false)
    static var hasSetupCKSubscriptions: Bool
    
    
    // MARK: Public User
    
    @BDStoredValue(in: .userDefaults, key: "kAppCache.userID", default: "")
    static var userID: String
    
    @BDStoredValue(in: .userDefaults, key: "kAppCache.username", default: "")
    static var username: String
    
    @BDStoredValue(in: .userDefaults, key: "kAppCache.userBio", default: "")
    static var userBio: String
    
    @BDStoredValue(in: .userDefaults, key: "kAppCache.publicUser", default: Data())
    static private var encodedPublicUser: Data
}


extension AppCache {
    
    static func cacheUser(_ user: PublicUser) {
        userID = user.userID
        username = user.username
        userBio = user.about
        if let data = try? JSONEncoder().encode(user) {
            encodedPublicUser = data
        }
    }
    
    static func cachedUser() -> PublicUser {
        do {
            let user = try JSONDecoder().decode(PublicUser.self, from: encodedPublicUser)
            return user
        } catch {
            return PublicUser(userID: AppCache.userID, username: AppCache.username, about: AppCache.userBio)
        }
    }
}
