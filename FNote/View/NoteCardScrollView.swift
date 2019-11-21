//
//  NoteCardScrollView.swift
//  FNote
//
//  Created by Veronica Sumariyanto on 11/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A scroll view for displaying a list of note cards.
///
/// Used in `NoteCardRelationshipView` and `NoteCollectionViewCardView`.
struct NoteCardScrollView: View {
    
    /// Note cards to display.
    var noteCards: [NoteCard]
    
    /// Selected note cards.
    var selectedCards = [NoteCard]()
    
    /// An action to perform when a card is selected.
    var onTap: ((NoteCard) -> Void)?
    
    /// A boolean to display quick buttons.
    var showQuickButtons = true
    
    /// A model used for searching.
    ///
    /// If its context is `nil` the search field will not be shown.
    @ObservedObject var searchModel = NoteCardSearchModel()
    
    var noteCardsToDisplay: [NoteCard] {
        if searchModel.context != nil, searchModel.isActive {
            return searchModel.searchFetchResult?.fetchedObjects ?? []
        } else {
            return noteCards
        }
    }
    
    
    // MARK: Body
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 24) {
                if searchModel.context != nil {
                    SearchTextField(
                        searchField: searchModel.searchField,
                        searchOption: searchModel.searchOption,
                        onCancel: searchModel.deactivate
                    )
                }
                
                ForEach(noteCardsToDisplay, id: \.uuid) { noteCard in
                    NoteCardView(
                        noteCard: noteCard,
                        showQuickButtons: false,
                        cardBackground: self.selectedCards.contains(noteCard) ? .appAccent : nil
                    )
                        .onTapGesture { self.onTap?(noteCard) }
                }
            }
            .padding()
        }
    }
}


struct NoteCardScrollView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardScrollView(noteCards: [], onTap: nil, searchModel: .init())
    }
}
