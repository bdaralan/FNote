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
        // NOTE: important check
        // need to check if newValue is nil
        // since supporting any optional and non-optional
        // with a generic Value
        // use String(describing:) to check for now
        // since cannot seem to find a better one
        let isNewValueNil = String(describing: newValue) == "nil"
        let newValue = isNewValueNil ? nil : newValue
        
        switch storage {
        
        case .userDefaults:
            UserDefaults.standard.set(newValue, forKey: key)
            
        case .iCloud:
            let store = NSUbiquitousKeyValueStore.default
            store.set(newValue, forKey: key)
            store.synchronize()
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
