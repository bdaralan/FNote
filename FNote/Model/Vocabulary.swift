//
//  Vocabulary.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


enum VocabularyFormality: Int {
    case unknown
    case informal
    case neutral
    case formal
}


struct Vocabulary {
    var original: String
    var translation: String
    var note: String
    var isFavorited: Bool
    var formality: VocabularyFormality
    
    var relations: [Vocabulary]
    var alternatives: [Vocabulary]
    
    var color: String
}
