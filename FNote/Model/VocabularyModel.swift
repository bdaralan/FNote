//
//  VocabularyModel.swift
//  FNote
//
//  Created by Dara Beng on 2/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


struct VocabularyModel {
    var native: String?
    var translation: String?
    var note: String?
    var politeness: String?
    var isFavorited: Bool?
    var relations: Set<Vocabulary> = []
    var alternatives: Set<Vocabulary> = []
    var collection: VocabularyCollection?
    
    
    func isValuesEqualTo(_ vocabulary: Vocabulary) -> Bool {
        return native == vocabulary.native
        && translation == vocabulary.translation
        && note == vocabulary.note
        && politeness == vocabulary.politeness
        && isFavorited == vocabulary.isFavorited
        && relations == vocabulary.relations
        && alternatives == vocabulary.alternatives
        && collection == vocabulary.collection
    }
    
    mutating func setValues(with vocabulary: Vocabulary) {
        native = vocabulary.native
        translation = vocabulary.translation
        note = vocabulary.note
        politeness = vocabulary.politeness
        isFavorited = vocabulary.isFavorited
        relations = vocabulary.relations
        alternatives = vocabulary.alternatives
        collection = vocabulary.collection
    }
}
