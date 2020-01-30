//
//  NoteCardSearchScope.swift
//  FNote
//
//  Created by Dara Beng on 10/29/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


enum NoteCardSearchScope {
    case translation
    case native
    case note
    
    var keyPath: String {
        switch self {
        case .translation: return #keyPath(NoteCard.translation)
        case .native: return #keyPath(NoteCard.native)
        case .note: return #keyPath(NoteCard.note)
        }
    }
}
