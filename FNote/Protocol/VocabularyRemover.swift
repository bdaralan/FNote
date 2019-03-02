//
//  VocabularyRemover.swift
//  FNote
//
//  Created by Dara Beng on 3/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


protocol VocabularyRemover: AnyObject {
    
    func removeVocabulary(_ vocabulary: Vocabulary, from collection: VocabularyCollection)
}
