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
    
    /// A view model used to handle search.
    @State private var  noteCardSearchModel = NoteCardSearchModel()
    
    /// A view reloader used to force reload view.
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    /// The note cards to display.
    var noteCards: [NoteCard] {
        if noteCardSearchModel.isActive {
            return noteCardSearchModel.searchFetchResult?.fetchedObjects ?? []
        } else {
            return noteCardDataSource.fetchedResult.fetchedObjects ?? []
        }
    }
    
    
    // Displaying the notecards from the collection in a ScrollView using their id and NoteCardCollectionViewCard
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchTextField(
                    searchField: noteCardSearchModel.searchField,
                    searchOption: noteCardSearchModel.searchOption,
                    onCancel: noteCardSearchModel.deactivate
                )
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                
                NoteCardScrollView(noteCards: noteCards, onTap: noteCardSelected, showQuickButton: false)
            }
            .navigationBarTitle("Relationships", displayMode: .inline)
            .navigationBarItems(leading: doneNavItem, trailing: searchNavItem)
            .onAppear(perform: setupView)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


// MARK: - Nav Items
extension NoteCardRelationshipView {
    
    // Button to show the add relationship sheet
    var searchNavItem: some View {
        Button(action: {}) {
            Image(systemName: "magnifyingglass")
                .imageScale(.large)
        }
    }
    
    var doneNavItem: some View {
        Button(action: onDone ?? {}) {
            Text("Done")
        }
        .hidden(onDone == nil)
    }
}

extension NoteCardRelationshipView {
    
    /// Add or remove the selected cards in the notecard's relationship set.
    func noteCardSelected(_ noteCard: NoteCard) {
        guard let context = self.noteCard.managedObjectContext else { return }
        
        let noteCard = noteCard.get(from: context)
        self.noteCard.objectWillChange.send()   // object will be changed, show the changes
        
        if self.noteCard.relationships.contains(noteCard) {
            self.noteCard.relationships.remove(noteCard)
        }
        else {
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


extension NoteCardRelationshipView {

    func setupView() {
        noteCardSearchModel.context = noteCardDataSource.updateContext
    }
}


struct NoteCardRelationshipView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardRelationshipView(noteCard: .init())
    }
}

// MARK: - Preview Only Related Words
extension NoteCardRelationshipView {
    
    func previewRelatedNoteCards() -> Set<NoteCard> {
        return self.noteCard.relationships
    }
}
