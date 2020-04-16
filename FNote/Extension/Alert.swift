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
    
    static func DeleteNoteCardCollection(_ collection: NoteCardCollection, onCancel: (() -> Void)?, onDelete: (() -> Void)?) -> Alert {
        let cardCount = collection.noteCards.count
        let countUnit = cardCount == 1 ? "card" : "cards"
        let title = Text("Delete Collection")
        let message = Text("Delete '\(collection.name)' with \(cardCount) \(countUnit).")
        let cancel = Alert.Button.cancel(onCancel)
        let delete = Alert.Button.destructive(Text("Delete"), action: onDelete)
        return Alert(title: title, message: message, primaryButton: cancel, secondaryButton: delete)
    }
    
    static func DeleteTag(_ tag: Tag, onCancel: (() -> Void)?, onDelete: (() -> Void)?) -> Alert {
        let title = Text("Delete Tag")
        let message = Text("Delete '\(tag.name)'. The tag will also be removed it from the cards.")
        let cancel = Alert.Button.cancel(onCancel)
        let delete = Alert.Button.destructive(Text("Delete"), action: onDelete)
        return Alert(title: title, message: message, primaryButton: cancel, secondaryButton: delete)
    }
    
    static func DeleteUnusedTags(onCancel: (() -> Void)?, onDelete: (() -> Void)?) -> Alert {
        let title = Text("Delete Unused Tags")
        let message = Text("All tags with zero count will also be deleted.")
        let cancel = Alert.Button.cancel(onCancel)
        let delete = Alert.Button.destructive(Text("Delete"), action: onDelete)
        return Alert(title: title, message: message, primaryButton: cancel, secondaryButton: delete)
    }
    
    static func DidCopyFileAlert(fileName: String) -> Alert {
        let title = Text("File Copied")
        let message = Text("File '\(fileName)' is copied to the document folder.")
        return Alert(title: title, message: message, dismissButton: .default(Text("Dismiss")))
    }
}
