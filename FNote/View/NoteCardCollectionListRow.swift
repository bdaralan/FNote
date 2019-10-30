//
//  NoteCardCollectionListRow.swift
//  FNote
//
//  Created by Andrew Flores on 10/30/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardCollectionListRow: View {
    
    @ObservedObject var collection: NoteCardCollection
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(collection.name)
                    .font(.headline)
                Spacer()
                Text(self.showCollectionCount(count: collection.noteCards.count))
                    .foregroundColor(.secondary)
                    .font(.subheadline )
                
            }
            
            Spacer() // hstack
            Image(systemName: "checkmark")
                .opacity(collection.uuid == AppCache.currentCollectionUUID ? 1 : 0)
        }
    }
}

extension NoteCardCollectionListRow {
    
    func showCollectionCount(count: Int) -> String {
        if count == 1 {
            return "\(count) CARD"
        } else {
            return "\(count) CARDS"
        }
    }
}

struct NoteCardCollectionListRow_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionListRow(collection: .init())
    }
}
