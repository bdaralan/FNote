//
//  NoteCardSearchScope.swift
//  FNote
//
//  Created by Dara Beng on 10/29/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


enum NoteCardSearchScope: CaseIterable {
    
    case translationOrNative
    case translation
    case native
    case tag
    case note
    
    var title: String {
        switch self {
        case .translationOrNative: return "translation | native"
        case .translation: return "translation"
        case .native: return "native"
        case .tag: return "tag"
        case .note: return "note"
        }
    }
    
    static func scope(withTitle: String) -> NoteCardSearchScope? {
        NoteCardSearchScope.allCases.first(where: { $0.title == withTitle })
    }
}


enum NoteCardSearchOption {
    
    /// Include those in the array.
    case include([NoteCard])
    
    /// Exclude those in the array.
    case exclude([NoteCard])
}
