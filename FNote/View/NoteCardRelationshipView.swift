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
    
    /// An array of notecards to display.
    var noteCards: [NoteCard]
    
    /// An action to perform when a notecard is long pressed
    var onLongPressed: (() -> Void)?
    
    /// An action to perform when the done button is pressed
    var onDone: (() -> Void)?
    
    
    // Displaying the notecards from the collection in a ScrollView using their id and NoteCardCollectionViewCard
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 24) {
                    ForEach(noteCards, id: \.uuid) { noteCard in
                        NoteCardCollectionViewCard(noteCard: noteCard, showQuickButton: false)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Relationships", displayMode: .inline)
            .navigationBarItems(leading: doneNavItem, trailing: searchNavItem)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


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
    
    // View that lets the user add unrelated cards
    var addRelationshipCardView: some View {
        Text("Add Relationship")
//        // Fetch all the notecards through the data source
//        let allNoteCards = noteCardDataSource.fetchedResult.fetchedObjects ?? []
//
//        // Filters allNoteCards to show unrelated cards by checking if it is in the relationship set
//        let unrelatedNoteCards = allNoteCards.filter { noteCard in
//            return !self.noteCard.relationships.contains(noteCard)
//        }
//
//        // Use NavigationView to allow user to cancel and add while in NoteCardRelationshipView
//        return NavigationView {
//            NoteCardRelationshipView(noteCards: unrelatedNoteCards, onLongPressed: nil, onDone: nil)
//                .navigationBarTitle("Add Relationships", displayMode: .inline)
//                .navigationBarItems(leading: Text("Cancel"), trailing: Text("Add"))
//        }
    }
}


struct NoteCardRelationshipView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardRelationshipView(noteCard: .init(), noteCards: [])
    }
}
