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
struct AppCache {
    
    // MARK: Typealias
    
    typealias UbiquityIdentityToken = (NSCoding & NSCopying & NSObjectProtocol)
    
    
    // MARK: Setup
    
    @BDPersist(in: .userDefaults, key: "kAppCache.ubiquityIdentityToken", default: nil)
    static var ubiquityIdentityToken: UbiquityIdentityToken?
    
    @BDPersist(in: .userDefaults, key: "kAppCache.currentCollectionUUID", default: nil)
    static var currentCollectionUUID: String?
    
    @BDPersist(in: .userDefaults, key: "kAppCache.shouldShowOnboard", default: true)
    static var shouldShowOnboard: Bool
    
    @BDPersist(in: .userDefaults, key: "kAppCache.lastKnownVersion", default: nil)
    static var lastKnownVersion: String?
    
    @BDPersist(in: .userDefaults, key: "kAppCache.hasSetupUserUpdateCKSubscription", default: false)
    static var hasSetupUserUpdateCKSubscription: Bool
    
    
    // MARK: Public User
    
    static let nEncodedPublicUserDidChange = Notification.Name(rawValue: "kAppCache.nEncodedPublicUserDidChange")
    
    @BDPersist(in: .userDefaults, key: "kAppCache.encodedPublicUser", default: Data(), post: nEncodedPublicUserDidChange)
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
