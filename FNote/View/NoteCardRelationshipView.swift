//
//  NoteCardRelationshipView.swift
//  FNote
//
//  Created by Veronica Sumariyanto on 10/16/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardRelationshipView: View {
    
    /// An array of notecards to display.
    var noteCards: [NoteCard]
    
    /// An action to perform when a notecard is long pressed
    var onLongPressed: (() -> Void)?
    
    /// An action to perform when the done button is pressed
    var onDone: (() -> Void)?
    
    // Displaying the notecards from the collection in a ScrollView using their id and NoteCardCollectionViewCard
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 24) {
                ForEach(noteCards, id: \.uuid) { noteCard in
                    NoteCardCollectionViewCard(noteCard: noteCard)
                }
            }
            .padding()
        }
    }
}

struct NoteCardRelationshipView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardRelationshipView(noteCards: [], onLongPressed: nil, onDone: nil)
    }
}
