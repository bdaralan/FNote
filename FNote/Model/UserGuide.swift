//
//  UserGuide.swift
//  FNote
//
//  Created by Dara Beng on 3/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


struct UserGuide: Decodable {
    let name: String
    let title: String
    let description: String
    let image: String
}


extension UserGuide {
    
    /// Load user guide from main bundle resource.
    static func load(resource: String) -> UserGuide? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let guide = try? JSONDecoder().decode(UserGuide.self, from: data) else { return nil }
        return guide
    }
}
