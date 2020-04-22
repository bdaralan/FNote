//
//  AppCache.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation
import CoreData
import BDSwiftility


/// An object that provide access to application's values stored in `UserDefaults`.
struct AppCache {
    
    // MARK: Typealias
    
    typealias UbiquityIdentityToken = (NSCoding & NSCopying & NSObjectProtocol)
    
    
    // MARK: Setup
    
    @UserStoredValue(in: .userDefaults, key: "kAppCache.ubiquityIdentityToken", defaultValue: nil)
    static var ubiquityIdentityToken: UbiquityIdentityToken?
    
    @UserStoredValue(in: .userDefaults, key: "kAppCache.currentCollectionUUID", defaultValue: nil)
    static var currentCollectionUUID: String?
    
    @UserStoredValue(in: .userDefaults, key: "kAppCache.shouldShowOnboard", defaultValue: true)
    static var shouldShowOnboard: Bool
    
    @UserStoredValue(in: .userDefaults, key: "kAppCache.lastKnownVersion", defaultValue: nil)
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
