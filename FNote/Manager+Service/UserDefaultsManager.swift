//
//  AppDefaults.swift
//  FNote
//
//  Created by Dara Beng on 3/12/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


class AppDefaults: Codable {
    
    var selectedCollectionRecordName: String?
    
    
    private init() {}
    
    
    /// Save changes.
    func saveChanges(qos: DispatchQoS.QoSClass = .utility) {
        DispatchQueue.global(qos: qos).async {
            let defaults = UserDefaults.standard
            let encoder = JSONEncoder()
            let encodedSelf = try? encoder.encode(self)
            defaults.setValue(encodedSelf, forKey: AppDefaults.key)
        }
    }
}


extension AppDefaults {
    
    static let standard = AppDefaults.load()
    
    static let key = "\(AppDefaults.self)"
    
    static private func load() -> AppDefaults {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()
        if let data = defaults.data(forKey: key), let appDefaults = try? decoder.decode(AppDefaults.self, from: data) {
            return appDefaults
        }
        let appDefaults = AppDefaults()
        appDefaults.saveChanges()
        return appDefaults
    }
}
