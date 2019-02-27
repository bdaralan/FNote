//
//  VocabularyViewController+Extension.swift
//  FNote
//
//  Created by Dara Beng on 1/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


extension VocabularyViewController {
    
    /// View controlelr mode.
    enum Mode {
        case view
        case edit
        case add
    }
    
    /// Controller's table view section type.
    enum InputSection: Int {
        case vocabulary
        case relation
        case note
    }
    
    /// Controller's table view row type in section.
    enum Input: Int {
        case native
        case translation
        case relations
        case alternatives
        case favorite
        case politeness
        case note
    }
}
