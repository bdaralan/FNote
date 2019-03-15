//
//  VocabularyCollectionValidator.swift
//  FNote
//
//  Created by Dara Beng on 3/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


struct VocabularyCollectionValidator {
    
    enum NameResult {
        case valid(String)
        case invalid(String)
        case duplicate(String)
    }
    
    func validateName(_ name: String, collections: [VocabularyCollection]) -> NameResult {
        let name = name.trimmingCharacters(in: .whitespaces)
        if name.isEmpty {
            return .invalid(name)
        } else if collections.map({ $0.name }).contains(name) {
            return .duplicate(name)
        } else {
            return .valid(name)
        }
    }
}
