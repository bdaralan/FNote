//
//  VocbularyAdder.swift
//  FNote
//
//  Created by Dara Beng on 2/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


protocol VocabularyAdder: AnyObject {
    
    func addNewVocabulary(to collection: VocabularyCollection)
}
