//
//  NoteCardScrollView.swift
//  FNote
//
//  Created by Veronica Sumariyanto on 11/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

/// Displays a list of notecards in a sheet. Used in NoteCardRelationshipView & NoteCollectionViewCardView.
struct NoteCardScrollView: View {
    
    var noteCards: [NoteCard]
    
    var onTap: ((NoteCard) -> Void)?
    
    var showQuickButton = true
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 24) {
                ForEach(noteCards, id: \.uuid) { noteCard in
                    NoteCardCollectionViewCard(
                        noteCard: noteCard,
                        showQuickButton: false
                    )
                        .onTapGesture { self.onTap?(noteCard) }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct NoteCardScrollView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardScrollView(noteCards: [], onTap: nil)
    }
}
