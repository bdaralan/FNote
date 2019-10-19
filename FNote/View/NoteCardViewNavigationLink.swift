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
    
    @EnvironmentObject var tagDataSource: TagDataSource
    
    @ObservedObject var noteCard: NoteCard
    
    var onDeleted: (() -> Void)?
    
    @ObservedObject private var navigationHandler = NavigationStateHandler()
    
    
    var body: some View {
        NavigationLink(destination: noteCardView, isActive: $navigationHandler.isPushed) {
            NoteCardCollectionViewCard(noteCard: noteCard)
        }
    }
}


extension NoteCardViewNavigationLink {
    
    var noteCardView: some View {
        NoteCardView(noteCard: noteCard, onDelete: deleteCard)
            .navigationBarTitle("Note Card", displayMode: .inline)
            .navigationBarItems(trailing: saveNavItem)
            .onAppear(perform: setupNavigationPopHandler)
    }
    
    var saveNavItem: some View {
        Button(action: saveChanges) {
            Text("Save").bold()
        }
        .disabled(!noteCard.isValid())
        .hidden(!noteCard.hasChangedValues())
    }
    
    func deleteCard() {
        navigationHandler.pop()
        noteCardDataSource.delete(noteCard, saveContext: true)
        onDeleted?()
    }
    
    func discardUnsavedChanges() {
        guard noteCard.hasChangedValues() else { return }
        noteCardDataSource.discardUpdateContext()
    }
    
    func saveChanges() {
        noteCard.objectWillChange.send() // tell the UI to refresh
        noteCardDataSource.saveUpdateContext()
        tagDataSource.saveUpdateContext()
    }
    
    func setupNavigationPopHandler() {
        navigationHandler.onPopped = discardUnsavedChanges
    }
}


struct NoteCardViewNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardViewNavigationLink(noteCard: .init())
    }
}
