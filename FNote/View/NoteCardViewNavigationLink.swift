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
    
    @State private var showDiscardAlert = false
    
    var onDeleted: (() -> Void)?
        
    
    var body: some View {
        NavigationLink(destination: noteCardView, tag: noteCard.uuid, selection: $selectedNoteCardID) {
            NoteCardCollectionViewCard(noteCard: noteCard)
        }
        .buttonStyle(NoteCardNavigationButtonStyle())
        .alert(isPresented: $showDiscardAlert, content: { self.discardAlert })
    }
}


extension NoteCardViewNavigationLink {
    
    var noteCardView: some View {
        NoteCardView(noteCard: noteCard, onDelete: deleteCard)
            .navigationBarTitle("Note Card", displayMode: .inline)
            .navigationBarItems(trailing: saveNavItem)
            .onDisappear(perform: checkUnsavedChanges)
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
    
    func discardChanges() {
        noteCard.objectWillChange.send() // tell the UI to refresh
        noteCardDataSource.discardUpdateContext()
    }
}


extension NoteCardViewNavigationLink {
    
    var discardAlert: Alert {
        let title = Text("Unsaved Changes")
        let message = Text("There are unsaved changes.\nWould you like to save the changes?")
        let save = Alert.Button.default(Text("Save"), action: saveChanges)
        let discard = Alert.Button.destructive(Text("Discard"), action: discardChanges)
        return Alert(title: title, message: message, primaryButton: discard, secondaryButton: save)
    }
    
    /// Check and show discard alert if there are unsaved changes.
    func checkUnsavedChanges() {
        guard noteCard.hasChangedValues() else { return }
        showDiscardAlert = true
    }
}


struct NoteCardViewNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardViewNavigationLink(noteCard: .init(), selectedNoteCardID: .constant(nil))
    }
}
