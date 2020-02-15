//
//  Bundle.swift
//  FNote
//
//  Created by Dara Beng on 2/14/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation


extension Bundle {
    
    func loadJSON<T>(resource: String, result: T.Type) -> T where T: Decodable {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            fatalError("🧨 attempt to load resource, but does not exist 🧨")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            fatalError("🧨 failed to load JSON resource with error: \(error) 🧨")
        }
    }
}
