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
    
    @EnvironmentObject var tagDataSource: TagDataSource
    
    /// The current note card collection user's selected.
    @ObservedObject var collection: NoteCardCollection
    
    @Binding var selectedNoteCardID: String?
    
    /// A flag used to show or hide create-new-note-card sheet.
    @State private var showCreateNewNoteCardSheet = false
        
    /// A view model used to handle search.
    @State private var  noteCardSearchModel = NoteCardSearchModel()
    
    /// A view reloader used to force reload view.
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    /// The note cards to display.
    var noteCards: [NoteCard] {
        guard noteCardSearchModel.isActive else { return noteCardDataSource.fetchedObjects }
        return noteCardSearchModel.matchedObjects
    }
    
    // MARK: Body
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 24) {
                    SearchTextField(
                        searchField: noteCardSearchModel.searchField,
                        searchOption: noteCardSearchModel.searchOption,
                        onCancel: noteCardSearchModel.deactivate
                    )
                        .onReceive(noteCardSearchModel.objectWillChange, perform: viewReloader.forceReload)
                    
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
            .navigationBarTitle(collection.name)
            .navigationBarItems(trailing: createNewNoteCardNavItem)
            .onAppear(perform: setupView)
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
            NoteCardDetailView(noteCard: noteCardDataSource.newObject!)
                .environmentObject(noteCardDataSource)
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
        let collectionInCreateContext = collection.get(from: noteCardDataSource.createContext)
        newNoteCard.collection = collectionInCreateContext
    
        let saveResult = noteCardDataSource.saveNewObject()
        
        switch saveResult {
        
        case .saved:
            noteCardDataSource.discardNewObject()
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
        viewReloader.forceReload()
    }
}


// MARK: - Setup & Fetch Method

extension NoteCardCollectionView {
    
    /// Prepare view and data when view appears.
    func setupView() {
        collection.objectWillChange.send()
        noteCardSearchModel.context = noteCardDataSource.updateContext
        noteCardSearchModel.matchingCollectionUUID = collection.uuid
    }
}


struct NoteCardCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionView(collection: .init(), selectedNoteCardID: .constant(nil))
    }
}
