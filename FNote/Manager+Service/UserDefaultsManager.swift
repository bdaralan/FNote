//
//  UserDefaultsManager.swift
//  FNote
//
//  Created by Dara Beng on 3/12/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


struct UserDefaultsManager {
    
    enum Key: String {
        case selectedVocabularyCollection
        
        var string: String {
            return "fnote.UserDefaultsManager.Key.\(rawValue)"
        }
    }
    
    
    static var userDefaults: UserDefaults {
        return UserDefaults.standard
    }
    
    
    static var selectedVocabularyCollectionRecordName: String? {
        return userDefaults.string(forKey: Key.selectedVocabularyCollection.string)
    }
    
    
    static func rememberSelectedVocabularyCollection(recordName: String) {
        userDefaults.setValue(recordName, forKey: Key.selectedVocabularyCollection.string)
    }
}
