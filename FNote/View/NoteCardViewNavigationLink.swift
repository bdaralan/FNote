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
    
    var onViewNoteCardDetail: ((NoteCard) -> Void)?
        
    
    var body: some View {
        NavigationLink(destination: noteCardDetailView, tag: noteCard.uuid, selection: $selectedNoteCardID) {
            NoteCardView(noteCard: noteCard)
        }
        .buttonStyle(NoteCardNavigationButtonStyle())
    }
}


extension NoteCardViewNavigationLink {
    
    var noteCardDetailView: some View {
        NoteCardDetailView(noteCard: noteCard, onDelete: deleteCard)
            .navigationBarTitle("Note Card", displayMode: .inline)
            .navigationBarItems(trailing: saveNavItem)
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


struct NoteCardViewNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardViewNavigationLink(noteCard: .init(), selectedNoteCardID: .constant(nil))
    }
}
