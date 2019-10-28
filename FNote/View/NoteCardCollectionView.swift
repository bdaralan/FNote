//
//  NoteCardCollectionView.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData


/// A view that displays note cards of the current selected note-card collection.
struct NoteCardCollectionView: View {
    
    /// A data source used to CRUD note card.
    @EnvironmentObject var noteCardDataSource: NoteCardDataSource
    
    @EnvironmentObject var tagDataSource: TagDataSource
    
    /// The current note card collection user's selected.
    @State private var currentCollection: NoteCardCollection?
    
    /// A flag used to show or hide create-new-note-card sheet.
    @State private var showCreateNewNoteCardSheet = false
    
    @State private var selectedNoteCardID: String?
    
    /// A view reloader used to force reload view.
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    /// A notification observer that listen to current collection did change notification.
    @ObservedObject private var currentCollectionObserver = NotificationObserver(name: .appCurrentCollectionDidChange)
    
    @ObservedObject private var searchField = SearchField()
    
    /// A fetch controller used for searching note cards.
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
    
    
    // MARK: Body
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 24) {
                    SearchTextField(searchField: searchField, onCancel: searchTextFieldCanceled)
                    ForEach(noteCards, id: \.uuid) { noteCard in
                        NoteCardViewNavigationLink(
                            noteCard: noteCard,
                            selectedNoteCardID: self.$selectedNoteCardID,
                            onDeleted: self.viewReloader.forceReload
                        )
                    }
                }
                .padding()
            }
            .navigationBarTitle(currentCollection?.name ?? "???")
            .navigationBarItems(trailing: createNewNoteCardNavItem)
            .onAppear(perform: setupOnAppear)
            .sheet(
                isPresented: $showCreateNewNoteCardSheet,
                onDismiss: cancelCreateNewNoteCard,
                content: createNewNoteCardSheet
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


// MARK: - Create View and Method

extension NoteCardCollectionView {
    
    /// A nav bar button for creating new note card.
    var createNewNoteCardNavItem: some View {
        Button(action: beginCreateNewNoteCard) {
            Image(systemName: "plus")
                .imageScale(.large)
        }
        .disabled(currentCollection == nil)
    }
    
    /// A sheet view for creating new note card.
    func createNewNoteCardSheet() -> some View {
        let cancelButton = Button("Cancel", action: cancelCreateNewNoteCard)
        
        let createButton = Button(action: commitCreateNewNoteCard) {
            Text("Create").bold()
        }
        .disabled(!noteCardDataSource.newObject!.hasValidInputs())
        .onReceive(noteCardDataSource.newObject!.objectWillChange) { _ in
            self.viewReloader.forceReload()
        }
        
        return NavigationView {
            NoteCardView(noteCard: noteCardDataSource.newObject!)
                .environmentObject(tagDataSource)
                .navigationBarTitle("New Note Card", displayMode: .inline)
                .navigationBarItems(leading: cancelButton, trailing: createButton)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    /// Start creating new note card.
    func beginCreateNewNoteCard() {
        noteCardDataSource.prepareNewObject()
        showCreateNewNoteCardSheet = true
    }
    
    /// Save the new note card.
    func commitCreateNewNoteCard() {
        // grab the current collection from the same context as the new note card
        // then assign it to the new note card's collection
        // will unwrapped optional values because they must exist
        let newNoteCard = noteCardDataSource.newObject!
        let collectionInCreateContext = currentCollection?.get(from: noteCardDataSource.createContext)
        newNoteCard.collection = collectionInCreateContext
    
        let saveResult = noteCardDataSource.saveNewObject()
        
        switch saveResult {
        
        case .saved:
            noteCardDataSource.discardNewObject()
            fetchNoteCards()
            viewReloader.forceReload()
            showCreateNewNoteCardSheet = false
        
        case .failed: break // TODO: show alert to inform user
        
        case .unchanged: break // this case will never happens for create
        }
    }
    
    /// Cancel creating new note card.
    func cancelCreateNewNoteCard() {
        noteCardDataSource.discardNewObject()
        noteCardDataSource.discardCreateContext()
        showCreateNewNoteCardSheet = false
    }
    
    func deleteNoteCard(_ notecard: NoteCard) {
        noteCardDataSource.delete(notecard, saveContext: true)
        fetchNoteCards()
    }
}


// MARK: - Setup & Fetch Method

extension NoteCardCollectionView {
    
    /// Prepare view and data when view appears.
    func setupOnAppear() {
        loadCurrentCollection()
        fetchNoteCards()
        setupCurrentCollectionObserver()
        setupSearchTextField()
    }
    
    /// Get user's current selected note-card collection.
    func loadCurrentCollection() {
        guard let currentCollectionUUID = AppCache.currentCollectionUUID else {
            currentCollection = nil
            return
        }

        guard currentCollection?.uuid != AppCache.currentCollectionUUID else { return }
        let request = NoteCardCollection.requestCollection(withUUID: currentCollectionUUID)
        let context = noteCardDataSource.fetchedResult.managedObjectContext
        currentCollection = try? context.fetch(request).first
    }
    
    /// Fetch note cards to displays.
    func fetchNoteCards() {
        if let currentCollectionUUID = currentCollection?.uuid {
            let request = NoteCard.requestNoteCards(forCollectionUUID: currentCollectionUUID)
            noteCardDataSource.performFetch(request)
        } else {
            noteCardDataSource.performFetch(NoteCard.requestNone())
        }
        viewReloader.forceReload()
    }
    
    /// Setup current collection observer action.
    func setupCurrentCollectionObserver() {
        currentCollectionObserver.onReceived = { notification in
            self.loadCurrentCollection()
            self.fetchNoteCards()
        }
    }
}


// MARK: - Search Text Field

extension NoteCardCollectionView {
    
    func setupSearchTextField() {
        searchField.onSearchTextDebounced = { searchText in
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
        }
        
        guard let collectionUUID = AppCache.currentCollectionUUID else {
            // cancel the search if cannot get current collection ID
            searchFetchResult = nil
            searchField.cancel()
            return
        }
        
        // being fetching with the search text if searchFetchResult is initialized.
        guard let searchFetchResult = searchFetchResult else { return }
        let request = NoteCard.requestNoteCards(forCollectionUUID: collectionUUID, predicate: searchText)
        searchFetchResult.fetchRequest.predicate = request.predicate
        searchFetchResult.fetchRequest.sortDescriptors = request.sortDescriptors
        try? searchFetchResult.performFetch()
    }
    
    /// Discard `searchFetchResult` on search text field canceled.
    func searchTextFieldCanceled() {
        searchFetchResult = nil
    }
}


struct NoteCardCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionView()
    }
}
