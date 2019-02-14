//
//  UserDefaults+KeyValue.swift
//  FNote
//
//  Created by Dara Beng on 2/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


extension UserDefaults {
    
    enum CloudKitServiceKey: CodingKey {
        case cachedAccountToken
    }
    
    func updateValue(_ value: Any?, forKey key: CloudKitServiceKey) {
        setValue(value, forKey: key.stringValue)
    }
}
