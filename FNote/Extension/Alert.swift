//
//  ReusableAlert.swift
//  FNote
//
//  Created by Dara Beng on 1/24/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


extension Alert {
 
    static func deleteNoteCard(_ noteCard: NoteCard) -> Alert {
        Alert(title: Text("Delete Note Card"))
    }
}
