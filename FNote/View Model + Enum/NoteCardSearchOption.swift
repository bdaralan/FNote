//
//  NoteCardSearchOption.swift
//  FNote
//
//  Created by Dara Beng on 10/29/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


enum NoteCardSearchOption: String, CaseIterable {
    case translationOrNative = "translation | native"
    case translation = "translation"
    case native = "native"
    case tag = "tag"
    case note = "note"
}
