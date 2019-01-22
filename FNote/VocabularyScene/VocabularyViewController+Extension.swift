//
//  VocabularyViewController+Extension.swift
//  FNote
//
//  Created by Dara Beng on 1/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


extension VocabularyViewController {
    
    /// Controller's table view section type
    enum InputSection: Int {
        case vocabulary
        case relation
        case note
    }
    
    /// Controller's table view row type in section
    enum Input: Int {
        case native, translation
        case relations, alternatives, favorite, politeness
        case note
    }
}
