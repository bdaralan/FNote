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
    
    
    @UserDefaultsOptionalValue(forKey: "kAppCache.ubiquityIdentityToken", default: nil, store: .local)
    static var ubiquityIdentityToken: UbiquityIdentityToken?
    
    @UserDefaultsOptionalValue(forKey: "kAppCache.currentCollectionUUID", default: nil, store: .local)
    static var currentCollectionUUID: String?
}


// MARK: - Non Optional Value

@propertyWrapper
struct UserDefaultsValue<T>: UserDefaultsStoreValue {
    
    let key: String
    
    let defaultValue: T
    
    let store: UserDefaultsStore
    
    var wrappedValue: T {
        set { updateValue(newValue) }
        get { value() ?? defaultValue }
    }
    
    
    init(forKey key: String, default value: T, store: UserDefaultsStore) {
        self.key = key
        self.defaultValue = value
        self.store = store
    }
}


// MARK: - Optional Value

@propertyWrapper
struct UserDefaultsOptionalValue<T>: UserDefaultsStoreValue {
    
    let key: String
    
    let defaultValue: T?
    
    let store: UserDefaultsStore
    
    var wrappedValue: T? {
        set { updateValue(newValue) }
        get { value() }
    }
    
    
    init(forKey key: String, default value: T?, store: UserDefaultsStore) {
        self.key = key
        self.defaultValue = value
        self.store = store
    }
}


// MARK: - Codable Value

@propertyWrapper
struct UserDefaultsCodableValue<T> where T: Codable {
    
    let key: String
    
    let defaultValue: T
    
    let store: UserDefaultsStore
    
    var wrappedValue: T {
        set { updateValue(newValue) }
        get { value() }
    }
    
    
    init(forKey key: String, default value: T, store: UserDefaultsStore) {
        self.key = key
        self.defaultValue = value
        self.store = store
    }
    
    func updateValue(_ newValue: T) {
        guard let data = try? JSONEncoder().encode(newValue) else { return }
        switch store {
        case .local:
            UserDefaults.standard.setValue(data, forKey: key)
        case .iCloud:
            NSUbiquitousKeyValueStore.default.setValue(data, forKey: key)
        }
    }
    
    func value() -> T {
        switch store {
        case .local:
            guard let data = UserDefaults.standard.data(forKey: key) else { return defaultValue }
            let object = try? JSONDecoder().decode(T.self, from: data)
            return object ?? defaultValue
        case .iCloud:
            guard let data = NSUbiquitousKeyValueStore.default.data(forKey: key) else { return defaultValue }
            let object = try? JSONDecoder().decode(T.self, from: data)
            return object ?? defaultValue
        }
    }
}


// MARK: - Protocol

protocol UserDefaultsStoreValue {
    
    var key: String { get }
    
    var store: UserDefaultsStore { get }
}


extension UserDefaultsStoreValue {
    
    func updateValue<T>(_ newValue: T?) {
        switch store {
        case .local:
            UserDefaults.standard.set(newValue, forKey: key)
        case .iCloud:
            let iCloudStore = NSUbiquitousKeyValueStore.default
            iCloudStore.set(newValue, forKey: key)
            iCloudStore.synchronize()
        }
    }
    
    func value<T>() -> T? {
        switch store {
        case .local:
            return UserDefaults.standard.object(forKey: key) as? T
        case .iCloud:
            return NSUbiquitousKeyValueStore.default.object(forKey: key) as? T
        }
    }
}


// MARK: - Enum

enum UserDefaultsStore {
    
    /// A store that sets/gets value to/from `UserDefaults`.
    case local
    
    /// A store that sets/gets value to/from `NSUbiquitousKeyValueStore`.
    case iCloud
}
