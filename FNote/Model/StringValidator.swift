//
//  StringValidator.swift
//  FNote
//
//  Created by Dara Beng on 3/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


struct StringValidator {
    
    enum NameResult {
        case empty
        case unique
        case duplicate
    }
    
    func validateNewName(_ newName: String, existingNames: [String]) -> NameResult {
        if newName.isEmpty {
            return .empty
        } else if existingNames.contains(newName) {
            return .duplicate
        } else {
            return .unique
        }
    }
}
