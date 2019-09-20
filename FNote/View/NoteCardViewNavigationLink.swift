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
    
    @ObservedObject private var navigationHandler = NavigationStateHandler()
    
    
    var body: some View {
        NavigationLink(destination: noteCardView, isActive: $navigationHandler.isPushed) {
            NoteCardCollectionViewCard(noteCard: noteCard)
        }
    }
}


extension NoteCardViewNavigationLink {
    
    var noteCardView: some View {
        NoteCardView(noteCard: noteCard)
            .navigationBarTitle("Note Card", displayMode: .inline)
            .navigationBarItems(trailing: saveNavItem)
            .onAppear { self.navigationHandler.onPopped = self.discardUnsavedChanges }
    }
    
    var saveNavItem: some View {
        let button = Button(action: saveChanges) {
            Text("Save").bold()
        }
        .disabled(!noteCard.isValid())
        
        if noteCard.hasChangedValues() {
            return AnyView(button)
        } else {
            return AnyView(button.hidden())
        }
    }
    
    func discardUnsavedChanges() {
        guard noteCard.hasChangedValues() else { return }
        noteCardDataSource.discardUpdateContext()
    }
    
    func saveChanges() {
        noteCard.objectWillChange.send() // tell the UI to refresh
        noteCardDataSource.saveUpdateContext()
    }
}


struct NoteCardViewNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardViewNavigationLink(noteCard: .init())
    }
}
