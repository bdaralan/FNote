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
    
    
    @UserDefaultsOptionalValue(forKey: "AppCache.kUbiquityIdentityToken", default: nil)
    static var ubiquityIdentityToken: UbiquityIdentityToken?
    
    @UserDefaultsOptionalValue(forKey: "AppCache.kCurrentCollectionUUID", default: nil)
    static var currentCollectionUUID: String?
    
    @UserDefaultsValue(forKey: "AppCache.Username", default: "StudiousStudent08")
    static var username: String
}


// MARK: - Non Optional Value

@propertyWrapper
struct UserDefaultsValue<T> {
    
    let key: String
    
    let defaultValue: T
    
    var wrappedValue: T {
        set { UserDefaults.standard.set(newValue, forKey: key) }
        get { UserDefaults.standard.value(forKey: key) as? T ?? defaultValue }
    }
    
    
    init(forKey key: String, default value: T) {
        self.key = key
        self.defaultValue = value
    }
}


// MARK: - Optional Value

@propertyWrapper
struct UserDefaultsOptionalValue<T> {
    
    let key: String
    
    let defaultValue: T?
    
    var wrappedValue: T? {
        set { UserDefaults.standard.set(newValue, forKey: key) }
        get { UserDefaults.standard.value(forKey: key) as? T}
    }
    
    
    init(forKey key: String, default value: T?) {
        self.key = key
        self.defaultValue = value
    }
}
