//
//  NoteCardScrollView.swift
//  FNote
//
//  Created by Veronica Sumariyanto on 11/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData


/// A scroll view for displaying a list of note cards.
///
/// Used in `NoteCardRelationshipView` and `NoteCollectionViewCardView`.
struct NoteCardScrollView: View {
    
    /// Note cards to display.
    var noteCards: [NoteCard]
    
    /// Selected note cards.
    var selectedCards = [NoteCard]()
    
    /// A boolean to display quick buttons.
    var showQuickButtons = true
    
    /// The context used to search note cards.
    var searchContext: NSManagedObjectContext?
    
    /// An action to perform when a card is selected.
    var onTap: ((NoteCard) -> Void)?
    
    /// A model used for searching.
    ///
    /// If its context is `nil` the search field will not be shown.
    ///
    /// - Note:
    ///   - Need to declare as `@State` so that when when view reload `onTap`,
    ///   the search text does not reset.
    ///   - Use `viewReloader` to refresh the UI
    @State private var searchModel = NoteCardSearchModel()
    
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    var noteCardsToDisplay: [NoteCard] {
        guard searchModel.context != nil, searchModel.isActive else { return noteCards }
        return searchModel.searchResults
    }
    
    
    // MARK: Body
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 24) {
                SearchTextField(
                    searchField: searchModel.searchField,
                    searchOption: searchModel.searchOption,
                    onCancel: searchModel.reset
                )
                    .onReceive(searchModel.objectWillChange, perform: { _ in self.viewReloader.forceReload() })
                
                ForEach(noteCardsToDisplay, id: \.uuid) { noteCard in
                    NoteCardView(
                        noteCard: noteCard,
                        showQuickButtons: false,
                        showSelection: self.selectedCards.contains(noteCard)
                    )
                        .onTapGesture(perform: { self.onTap?(noteCard) })
                }
            }
            .padding()
            .onAppear(perform: setupSearchModel)
        }
    }
}


extension NoteCardScrollView {
    
    func setupSearchModel() {
        searchModel.context = searchContext
        searchModel.noteCardSearchOptions = [.include(noteCards)]
    }
}


struct NoteCardScrollView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardScrollView(noteCards: [], onTap: nil)
    }
}
