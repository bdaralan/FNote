//
//  HomeNoteCardView.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData


struct HomeNoteCardView: View {
    
    @EnvironmentObject var appState: AppState
    
    var viewModel: NoteCardCollectionViewModel
    
    var collection: NoteCardCollection
    
    @State private var sheet: Sheet?
    @State private var noteCardFormModel: NoteCardFormModel?
    
    var body: some View {
        NavigationView {
            NoteCardCollectionViewWrapper(viewModel: viewModel)
                .navigationBarTitle(Text(collection.name), displayMode: .large)
                .navigationBarItems(trailing: createNoteCardNavItem)
                .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet, content: presentationSheet)
        .onAppear(perform: setupOnAppear)
    }
}


// MARK: - Sheet

extension HomeNoteCardView {
    
    enum Sheet: Identifiable {
        var id: Self { self }
        case noteCardForm
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .noteCardForm:
            return NoteCardForm(viewModel: noteCardFormModel!)
        }
    }
    
    func setupOnAppear() {
        viewModel.noteCards = appState.currenNoteCards
        viewModel.onNoteCardSelected = beginEditNoteCard
    }
}



// MARK: - Create Note Card

extension HomeNoteCardView {
    
    var createNoteCardNavItem: some View {
        NavigationBarButton(imageName: "plus", action: beginCreateNoteCard)
    }
    
    func beginCreateNoteCard() {
        noteCardFormModel = .init(collection: collection)
        
        noteCardFormModel?.selectableCollections = appState.collections
        noteCardFormModel?.selectableRelationships = appState.currenNoteCards
        noteCardFormModel?.selectableTags = appState.tags
        
        noteCardFormModel?.onCancel = cancelCreateNoteCard
        noteCardFormModel?.onCommit = commitCreateNoteCard
        
        noteCardFormModel?.commitTitle = "Create"
        noteCardFormModel?.navigationTitle = "New Note Card"
        
        sheet = .noteCardForm
    }
    
    func cancelCreateNoteCard() {
        noteCardFormModel = nil
        sheet = nil
    }
    
    func commitCreateNoteCard() {
        guard let formModel = noteCardFormModel else { return }
        let createRequest = formModel.createNoteCardCUDRequest()
        let result = appState.createNoteCard(with: createRequest)
        
        switch result {
        case .created(_, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            sheet = nil
        
        case .failed: // TODO: show alert
            sheet = nil
        
        case .updated, .deleted:
            fatalError("🧨 hmm... tried to \(result) object in commitCreateNoteCard method 🧨")
        }
    }
}


// MARK: - Edit Note Card

extension HomeNoteCardView {
    
    func beginEditNoteCard(_ noteCard: NoteCard) {
        guard let collection = noteCard.collection else { return }
        noteCardFormModel = .init(collection: collection)
        
        noteCardFormModel?.selectableCollections = appState.collections
        noteCardFormModel?.selectableRelationships = appState.currenNoteCards
        noteCardFormModel?.selectableTags = appState.tags
        
        noteCardFormModel?.onCancel = cancelEditNoteCard
        noteCardFormModel?.onCommit = { self.commitEditNoteCard(noteCard) }
        
        noteCardFormModel?.update(with: noteCard)
        noteCardFormModel?.commitTitle = "Update"
        noteCardFormModel?.navigationTitle = "Note Card Detail"
        noteCardFormModel?.nativePlaceholder = noteCard.native
        noteCardFormModel?.translationPlaceholder = noteCard.translation
        
        sheet = .noteCardForm
    }
    
    func cancelEditNoteCard() {
        noteCardFormModel = nil
        sheet = nil
    }
    
    func commitEditNoteCard(_ noteCard: NoteCard) {
        sheet = nil
    }
}


struct HomeNoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        HomeNoteCardView(viewModel: .init(), collection: .sample)
    }
}
