//
//  TagRow.swift
//  FNote
//
//  Created by Andrew Flores on 10/30/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct TagRow: View {
    
    @ObservedObject var tag: Tag
    
    var contextMenus: Set<ContextMenu> = []
    var onContextMenuSelected: ((ContextMenu, Tag) -> Void)?
    
    var noteCardCount: String {
        let count = tag.noteCards.count
        let unit = count == 1 ? "CARD" : "CARDS"
        return "\(count) \(unit)"
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(tag.name)
                .font(.headline)
            Spacer()
            Text(noteCardCount)
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(Color.noteCardBackground)
        .cornerRadius(10)
        .shadow(color: Color.primary.opacity(0.1), radius: 1, x: -1, y: 1)
        .contextMenu(menuItems: contextMenuItems)
    }
}


// MARK - Context Menu

extension TagRow {
    
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
        onContextMenuSelected?(menu, tag)
    }
}


extension TagRow {
    
    enum ContextMenu {
        case rename
        case delete
    }
}


struct TagListRow_Previews: PreviewProvider {
    static var previews: some View {
        TagRow(tag: .init())
    }
}
