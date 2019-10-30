//
//  NoteCardRelationshipView.swift
//  FNote
//
//  Created by Veronica Sumariyanto on 10/16/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData

struct NoteCardRelationshipView: View {
    
    @EnvironmentObject var noteCardDataSource: NoteCardDataSource
    
    @ObservedObject var noteCard: NoteCard
    
    /// An action to perform when a notecard is long pressed
    var onLongPressed: (() -> Void)?
    
    /// An action to perform when the done button is pressed
    var onDone: (() -> Void)?
    
    @ObservedObject private var searchField = SearchField()
    
    @ObservedObject private var searchOption = SearchOption()
    
    ///
    /// - Important:
    ///   - Initialize its value to tell the view that it is in searching state.
    ///   - Make sure to set the value back to `nil` to tell the view that it is not in searching state.
    ///   - Use the computed property `isSearching` when one to check the state.
    @State private var searchFetchResult: NSFetchedResultsController<NoteCard>?
    
    /// A boolean indicate if the view is in searching state.
    var isSearching: Bool {
        searchFetchResult != nil
    }
    
    /// The note cards to display.
    var noteCards: [NoteCard] {
        if isSearching {
            return searchFetchResult?.fetchedObjects ?? []
        } else {
            return noteCardDataSource.fetchedResult.fetchedObjects ?? []
        }
    }
    // Displaying the notecards from the collection in a ScrollView using their id and NoteCardCollectionViewCard
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 24) {
                    SearchTextField(
                        searchField: searchField,
                        searchOption: searchOption,
                        onCancel: searchTextFieldCanceled
                    )
                    ForEach(noteCards, id: \.uuid) { noteCard in
                        NoteCardCollectionViewCard(
                            noteCard: noteCard,
                            showQuickButton: false,
                            cardBackground: self.cardBackgroundColor(for: noteCard)
                        )
                            .hidden(noteCard.uuid == self.noteCard.uuid)
                            .onTapGesture { self.noteCardSelected(noteCard) }
                    }
                }
                .padding()
            }
            .navigationBarTitle("Relationships", displayMode: .inline)
            .navigationBarItems(leading: doneNavItem, trailing: searchNavItem)
            .onAppear(perform: setupSearchTextField)
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

struct NoteCardRelationshipView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardRelationshipView(noteCard: .init())
    }
}

// MARK: - Search Field
extension NoteCardRelationshipView {

    func setupSearchTextField() {
        searchField.onSearchTextDebounced = { searchText in
            self.fetchNoteCards(searchText: searchText)
        }
        
        /// The options the user can choose when searching for a notecard.
        let options = NoteCardSearchOption.allCases.map({ $0.rawValue })
        searchOption.options = options
        searchOption.selectedOptions = [options.first!]
        searchOption.allowsMultipleSelections = false
        searchOption.allowsEmptySelection = false
        
        searchOption.selectedOptionsChanged = {
            let searchText = self.searchField.searchText
            self.fetchNoteCards(searchText: searchText)
        }
    }
    
    
    /// Fetch note cards using `searchFetchResult` with the given search text.
    /// - Parameter searchText: The search text.
    func fetchNoteCards(searchText: String) {
        if !searchText.isEmpty, searchFetchResult == nil {
            // initialize searchFetchResult when start searching
            // only does so if there is text in the search text field
            // this prevents unnecessary fetching in the case where user
            // activates the search but then cancels right away
            searchFetchResult = .init(
                fetchRequest: NoteCard.requestNone(),
                managedObjectContext: noteCardDataSource.updateContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            print(searchText)
        }
        
        guard let collectionUUID = AppCache.currentCollectionUUID else {
            // cancel the search if cannot get current collection ID
            searchFetchResult = nil
            searchField.cancel()
            return
        }
        
        // begin fetching with the search text if searchFetchResult is initialized.
        guard let searchFetchResult = searchFetchResult else { return }
        
        // safe to unwrapped here because already setup to always have one state
        // see setupSearchTextField() method
        let searchState = NoteCardSearchOption(rawValue: searchOption.selectedOptions.first!)!
        
        // Use the second requestNoteCards defined in Notecard that includes the collectionUUID, searchText, and searchState
        let request = NoteCard.requestNoteCards(
            forCollectionUUID: collectionUUID,
            searchText: searchText,
            search: searchState)
        
        searchFetchResult.fetchRequest.predicate = request.predicate
        searchFetchResult.fetchRequest.sortDescriptors = request.sortDescriptors
        try? searchFetchResult.performFetch()
        
    }
    
    /// Discard `searchFetchResult` on search text field canceled.
    func searchTextFieldCanceled() {
        searchFetchResult = nil
        searchOption.selectedOptions = [searchOption.options.first!]
    }
}
