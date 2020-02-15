//
//  AppCache.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation
import CoreData


/// An object that provide access to application's values stored in `UserDefaults`.
struct AppCache {
    
    typealias UbiquityIdentityToken = (NSCoding & NSCopying & NSObjectProtocol)
    
    
    @UserStoredValue(in: .userDefaults, key: "kAppCache.ubiquityIdentityToken", defaultValue: nil)
    static var ubiquityIdentityToken: UbiquityIdentityToken?
    
    @UserStoredValue(in: .userDefaults, key: "kAppCache.currentCollectionUUID", defaultValue: nil)
    static var currentCollectionUUID: String?
    
    @UserStoredValue(in: .userDefaults, key: "kAppCache.shouldShowOnboard", defaultValue: true)
    static var shouldShowOnboard: Bool
}
