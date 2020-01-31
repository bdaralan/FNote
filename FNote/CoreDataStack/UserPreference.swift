//
//  UserPreference.swift
//  FNote
//
//  Created by Dara Beng on 1/30/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation


class UserPreference: ObservableObject {
    
    static let shared = UserPreference()
    
    @UserStoredValue(in: .iCloud, key: "kUserPreference.preferredColorScheme", defaultValue: 0)
    var preferredColorScheme: Int
        
    @UserStoredValue(in: .iCloud, key: "kUserPreference.useMarkdown", defaultValue: false)
    var useMarkdown: Bool
    
    
    private init() {}
}
