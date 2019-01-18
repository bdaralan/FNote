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


class Vocabulary {
    var original: String
    var translation: String
    var note: String
    var isFavorited: Bool
    var formality: VocabularyFormality
    
    var relations: [Vocabulary]
    var alternatives: [Vocabulary]

    init() {
        #warning("sample init, must be removed")
        original = "안녕하세요"
        translation = "Hello"
        note = ""
        isFavorited = false
        formality = .formal
        relations = []
        alternatives = []
    }
}
