//
//  ReusableAlert.swift
//  FNote
//
//  Created by Dara Beng on 1/24/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


extension Alert {
 
    static func DeleteNoteCard(_ noteCard: NoteCard, onCancel: (() -> Void)?, onDelete: (() -> Void)?) -> Alert {
        let title = Text("Delete Card")
        let message = Text("Delete '\(noteCard.native)'")
        let cancel = Alert.Button.cancel(onCancel)
        let delete = Alert.Button.destructive(Text("Delete"), action: onDelete)
        return Alert(title: title, message: message, primaryButton: cancel, secondaryButton: delete)
    }
}
