//
//  NoteCardCollectionRow.swift
//  FNote
//
//  Created by Brittney Witts on 10/30/19.
//  Copyright © 2019 Brittney Witts. All rights reserved.
//

import SwiftUI


struct NoteCardCollectionRow: View {
    
    @ObservedObject var collection: NoteCardCollection
    
    var checked = false
    
    var contextMenus: Set<ContextMenu> = []
    var onContextMenuSelected: ((ContextMenu, NoteCardCollection) -> Void)?
    
    var noteCardCount: String {
        let count = collection.noteCards.count
        let unit = count == 1 ? "CARD" : "CARDS"
        return "\(count) \(unit)"
    }
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(collection.name)
                    .font(.headline)
                Spacer()
                Text(noteCardCount)
                    .foregroundColor(.secondary)
                    .font(.subheadline )
            }
            
            Spacer()
            
            if checked {
                Image(systemName: "checkmark")
                    .transition(AnyTransition.scale.animation(Animation.easeInOut(duration: 0.15)))
            }
        }
        .padding()
        .background(Color.noteCardBackground)
        .cornerRadius(10)
        .shadow(color: Color.primary.opacity(0.1), radius: 1, x: -1, y: 1)
        .contextMenu(menuItems: contextMenuItems)
    }
}

extension NoteCardCollectionRow {
    
    func contextMenuItems() -> some View {
        Group {
            if contextMenus.contains(.rename) {
                Button(action: { self.handleContextMenuItemTapped(.rename) }) {
                    Text("Rename")
                    Image(systemName: "square.and.pencil")
                }
            }
            
            if contextMenus.contains(.delete) {
                Button(action: { self.handleContextMenuItemTapped(.delete) }) {
                    Text("Delete")
                    Image(systemName: "trash")
                }
            }
        }
    }
    
    func handleContextMenuItemTapped(_ menu: ContextMenu) {
        onContextMenuSelected?(menu, collection)
    }
}


extension NoteCardCollectionRow {
    
    enum ContextMenu {
        case rename
        case delete
    }
}


struct NoteCardCollectionListRow_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionRow(collection: .sample)
    }
}
