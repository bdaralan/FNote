//
//  Vocabulary.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


enum VocabularyPoliteness: String, CaseIterable {
    case unknown = "Unknown"
    case informal = "Informal"
    case neutral = "Neutral"
    case formal = "Formal"
    
    #warning("assets have not been added yet")
    var image: UIImage {
        switch self {
        case .unknown: return UIImage(named: "polite-unknown")!
        case .informal: return UIImage(named: "polite-informal")!
        case .neutral: return UIImage(named: "polite-neutral")!
        case .formal: return UIImage(named: "polite-formal")!
        }
    }
}


class Vocabulary: NSObject {
    var native: String
    var translation: String
    var note: String
    var isFavorited: Bool
    var politeness: VocabularyPoliteness
    
    var relations: [Vocabulary]
    var alternatives: [Vocabulary]

    override init() {
        #warning("sample init, must be removed")
        native = "안녕하세요"
        translation = "Hello"
        note = ""
        isFavorited = false
        politeness = .formal
        relations = []
        alternatives = []
    }
}
