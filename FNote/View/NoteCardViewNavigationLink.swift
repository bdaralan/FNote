//
//  NoteCardViewNavigationLink.swift
//  FNote
//
//  Created by Dara Beng on 9/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A navigation link view for viewing or editing note card.
struct NoteCardViewNavigationLink: View {
        
    @EnvironmentObject var noteCardDataSource: NoteCardDataSource
    
    @ObservedObject var noteCard: NoteCard
    
    /// The UUID of the note card to be pushed onto the navigation view.
    @Binding var selectedNoteCardID: String?
    
    @State private var showChangeCollectionAlert = false
    @State private var newCollectionToChange: NoteCardCollection?
    
    var onDeleted: (() -> Void)?
    
    var onViewNoteCardDetail: ((NoteCard) -> Void)?
    
    var onCollectionChanged: ((NoteCardCollection) -> Void)?
        
    
    var body: some View {
        NavigationLink(destination: noteCardDetailView, tag: noteCard.uuid, selection: $selectedNoteCardID) {
            NoteCardView(noteCard: noteCard)
        }
        .buttonStyle(NoteCardNavigationButtonStyle())
    }
}


extension NoteCardViewNavigationLink {
    
    var noteCardDetailView: some View {
        NoteCardDetailView(
            noteCard: noteCard,
            onDelete: deleteCard,
            onCollectionChange: beginChangeCollection
        )
            .navigationBarTitle("Note Card", displayMode: .inline)
            .navigationBarItems(trailing: saveNavItem)
            .alert(isPresented: $showChangeCollectionAlert, content: changeCollectionConfirmAlert)
            .onAppear(perform: { self.onViewNoteCardDetail?(self.noteCard) })
    }
    
    var saveNavItem: some View {
        Button(action: saveChanges) {
            Text("Save").bold()
        }
        .disabled(!noteCard.isValid())
        .hidden(!noteCard.hasChangedValues())
    }
    
    func deleteCard() {
        noteCardDataSource.delete(noteCard, saveContext: true)
        onDeleted?()
    }
    
    func saveChanges() {
        noteCard.objectWillChange.send() // tell the UI to refresh
        noteCardDataSource.saveUpdateContext()
    }
}


extension NoteCardViewNavigationLink {
    
    func changeCollectionConfirmAlert() -> Alert {
        let newCollectionName = newCollectionToChange?.name ?? ""
        let title = Text("Move Note Card")
        let message = Text("All note card's links will be removed once moved to '\(newCollectionName)' collection.")
        let cancel = Alert.Button.cancel(cancelChangeCollection)
        let move = Alert.Button.default(Text("Move"), action: commitChangeCollection)
        return Alert(title: title, message: message, primaryButton: cancel, secondaryButton: move)
    }
    
    func beginChangeCollection(with collection: NoteCardCollection) {
        newCollectionToChange = collection
        showChangeCollectionAlert = true
    }
    
    func commitChangeCollection() {
        guard let collection = newCollectionToChange, !noteCard.hasChangedValues() else { return }
        noteCard.collection = collection
        noteCard.relationships.removeAll()
        saveChanges()
        showChangeCollectionAlert = false
        onCollectionChanged?(collection)
    }
    
    func cancelChangeCollection() {
        newCollectionToChange = nil
        showChangeCollectionAlert = false
    }
}


struct NoteCardViewNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardViewNavigationLink(noteCard: .init(), selectedNoteCardID: .constant(nil))
    }
}
