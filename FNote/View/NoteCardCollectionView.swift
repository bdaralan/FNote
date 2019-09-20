//
//  NoteCardCollectionView.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A view that displays note cards of the current selected note-card collection.
struct NoteCardCollectionView: View {
    
    /// A data source used to CRUD note card.
    @EnvironmentObject var noteCardDataSource: NoteCardDataSource
    
    /// A view reloader used to force reload view.
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    /// The current note card collection user's selected.
    @State private var currentCollection: NoteCardCollection?
    
    /// A flag used to show or hide create-new-note-card sheet.
    @State private var showCreateNewNoteCardSheet = false
    
    
    // MARK: Body
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack (spacing: 0){
                    ForEach(noteCardDataSource.fetchedResult.fetchedObjects ?? []) { noteCard in
                        NoteCardViewNavigationLink(noteCard: noteCard)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.vertical)
            }
            .onAppear(perform: setupOnAppear)
            .navigationBarTitle(currentCollection?.name ?? "???")
            .navigationBarItems(trailing: createNewNoteCardNavItem)
            .sheet(
                isPresented: $showCreateNewNoteCardSheet,
                onDismiss: cancelCreateNewNoteCard,
                content: createNewNoteCardSheet
            )
        }
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
        
        let sheet = NavigationView {
            NoteCardView(noteCard: noteCardDataSource.newObject!)
                .navigationBarTitle("New Note Card", displayMode: .inline)
                .navigationBarItems(leading: cancelButton, trailing: createButton)
        }
        
        return sheet
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
}


// MARK: - Setup & Fetch Method

extension NoteCardCollectionView {
    
    /// Prepare view and data when view appears.
    func setupOnAppear() {
        loadCurrentCollection()
        fetchNoteCards()
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
        let currentCollectionUUID = currentCollection?.uuid
        let request = NoteCard.requestNoteCards(forCollectionUUID: currentCollectionUUID)
        noteCardDataSource.performFetch(request)
    }
}


struct NoteCardCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionView()
    }
}
