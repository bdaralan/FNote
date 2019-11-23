//
//  NoteCardRelationshipView.swift
//  FNote
//
//  Created by Veronica Sumariyanto on 10/16/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardRelationshipView: View {
    
    @EnvironmentObject var noteCardDataSource: NoteCardDataSource
    
    @ObservedObject var noteCard: NoteCard
    
    /// An action to perform when a notecard is long pressed
    var onLongPressed: (() -> Void)?
    
    /// An action to perform when the done button is pressed
    var onDone: (() -> Void)?
    
    /// A view reloader used to force reload view.
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    @State private var noteCards = [NoteCard]()
    
    
    // MARK: Body
    // Displaying the notecards from the collection in a ScrollView using their id and NoteCardCollectionViewCard
    
    var body: some View {
        NavigationView {
            NoteCardScrollView(
                noteCards: noteCards,
                selectedCards: Array(noteCard.relationships),
                showQuickButtons: false,
                searchContext: noteCard.managedObjectContext,
                onTap: noteCardSelected
            )
                .navigationBarTitle("Relationships", displayMode: .inline)
                .navigationBarItems(leading: doneNavItem)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: setupView)
    }
}


// MARK: - Nav Items

extension NoteCardRelationshipView {
    
    var doneNavItem: some View {
        Button("Done", action: onDone ?? {})
            .hidden(onDone == nil)
    }
}


// MARK: - Method

extension NoteCardRelationshipView {
    
    /// Add or remove the selected cards in the notecard's relationship set.
    func noteCardSelected(_ noteCard: NoteCard) {
        guard let context = self.noteCard.managedObjectContext else { return }
        
        let noteCard = noteCard.get(from: context)
        self.noteCard.objectWillChange.send()   // object will be changed, show the changes
        
        if self.noteCard.relationships.contains(noteCard) {
            self.noteCard.relationships.remove(noteCard)
        } else {
            self.noteCard.relationships.insert(noteCard)
        }
    }
    
    /// Set the background color for selected cards.
    func cardBackgroundColor(for noteCard: NoteCard) -> Color? {
        if self.noteCard.relationships.contains(where: { $0.uuid == noteCard.uuid }) {
            return .appAccent // return orange color if card is in the relationships
        }
        return nil // return default color if card is not in relationship
    }
}


// MARK: - Setup

extension NoteCardRelationshipView {

    func setupView() {
        let allCards = noteCardDataSource.fetchedObjects
        noteCards = allCards.filter({ $0.uuid != noteCard.uuid })
    }
}


struct NoteCardRelationshipView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardRelationshipView(noteCard: .init())
    }
}
