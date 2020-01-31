//
//  UserStoredValue.swift
//  FNote
//
//  Created by Dara Beng on 1/30/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation
import SwiftUI


@propertyWrapper
struct UserStoredValue<Value> {
    
    // MARK: Property
    
    let storage: Storage
    
    let key: String
    
    let defaultValue: Value
    
    
    // MARK: Value
    
    var wrappedValue: Value {
        set { setValue(newValue) }
        get { getValue() }
    }
    
    var binding: Binding<Value> {
        .init(
            get: { self.getValue() },
            set: { self.setValue($0) }
        )
    }

    
    // MARK: Constructor
    
    init(in storage: Storage, key: String, defaultValue: Value) {
        self.storage = storage
        self.key = key
        self.defaultValue = defaultValue
    }
    
    
    // MARK: Method
    
    func setValue(_ newValue: Value) {
        switch storage {
        
        case .userDefaults:
            UserDefaults.standard.setValue(newValue, forKeyPath: key)
        
        case .iCloud:
            NSUbiquitousKeyValueStore.default.setValue(newValue, forKey: key)
        }
    }
    
    func getValue() -> Value {
        switch storage {
        
        case .userDefaults:
            let value = UserDefaults.standard.object(forKey: key) as? Value
            return value ?? defaultValue
        
        case .iCloud:
            let value = NSUbiquitousKeyValueStore.default.object(forKey: key) as? Value
            return value ?? defaultValue
        }
    }
}


extension UserStoredValue {
    
    enum Storage {
        
        /// Store value in `UserDefaults`
        case userDefaults
        
        /// Store value in `NSUbiquitousKeyValueStore`
        /// - Important: Must enable iCloud's Key-value storage in Signing & Capabilities
        case iCloud
    }
}
