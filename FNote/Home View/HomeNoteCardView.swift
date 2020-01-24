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
        viewModel.onNoteCardQuickButtonTapped = handleNoteCardQuickButtonTapped
    }
}



// MARK: - Create Note Card

extension HomeNoteCardView {
    
    var createNoteCardNavItem: some View {
        NavigationBarButton(imageName: "plus", action: beginCreateNoteCard)
    }
    
    func beginCreateNoteCard() {
        let formModel = NoteCardFormModel(collection: collection)
        noteCardFormModel = formModel
        
        formModel.selectableCollections = appState.collections
        formModel.selectableRelationships = appState.currenNoteCards
        formModel.selectableTags = appState.tags
        
        formModel.onCancel = cancelCreateNoteCard
        formModel.onCommit = commitCreateNoteCard
        
        formModel.onCollectionSelected = { collection in
            self.handleNoteCardFormCollectionSelected(collection, formModel: formModel)
        }
        
        formModel.onRelationshipSelected = { relationship in
            self.handleNoteCardFormRelationshipSelected(relationship, formModel: formModel)
        }
        
        formModel.onTagSelected = { tag in
            self.handleNoteCardFormTagSelected(tag, formModel: formModel)
        }
        
        noteCardFormModel?.commitTitle = "Create"
        noteCardFormModel?.navigationTitle = "New Card"
        
        sheet = .noteCardForm
    }
    
    func commitCreateNoteCard() {
        guard let formModel = noteCardFormModel else { return }
        let createRequest = formModel.createNoteCardCUDRequest()
        let result = appState.createNoteCard(with: createRequest)
        handleNoteCardCUDResult(result)
    }
    
    func cancelCreateNoteCard() {
        noteCardFormModel = nil
        sheet = nil
    }
}


// MARK: - Edit Note Card

extension HomeNoteCardView {
    
    func beginEditNoteCard(_ noteCard: NoteCard) {
        guard let collection = noteCard.collection else { return }
        let formModel = NoteCardFormModel(collection: collection, noteCard: noteCard)
        noteCardFormModel = formModel
        
        formModel.selectableCollections = appState.collections
        formModel.selectableRelationships = appState.currenNoteCards
        formModel.selectableTags = appState.tags
        
        formModel.onCancel = cancelEditNoteCard
        formModel.onCommit = { self.commitEditNoteCard(noteCard) }
        
        formModel.onCollectionSelected = { collection in
            self.handleNoteCardFormCollectionSelected(collection, formModel: formModel)
        }
        
        formModel.onRelationshipSelected = { relationship in
            self.handleNoteCardFormRelationshipSelected(relationship, formModel: formModel)
        }
        
        formModel.onTagSelected = { tag in
            self.handleNoteCardFormTagSelected(tag, formModel: formModel)
        }
        
        formModel.update(with: noteCard)
        formModel.commitTitle = "Update"
        formModel.navigationTitle = "Card Detail"
        formModel.nativePlaceholder = noteCard.native
        formModel.translationPlaceholder = noteCard.translation
        
        sheet = .noteCardForm
    }
    
    func cancelEditNoteCard() {
        noteCardFormModel = nil
        sheet = nil
    }
    
    func commitEditNoteCard(_ noteCard: NoteCard) {
        guard let formModel = noteCardFormModel else { return }
        let request = formModel.createNoteCardCUDRequest()
        let result = appState.updateNoteCard(noteCard, with: request)
        handleNoteCardCUDResult(result)
    }
    
    func handleNoteCardQuickButtonTapped(_ button: NoteCardCell.QuickButtonType, noteCard: NoteCard) {
        switch button {
        case .relationship: break
        
        case .tag: break
        
        case .favorite:
            noteCard.isFavorited.toggle()
            noteCard.managedObjectContext?.quickSave()
        
        case .note: break
        }
    }
}


// MARK: - Form Model Handler

extension HomeNoteCardView {
    
    func handleNoteCardFormCollectionSelected(_ collection: NoteCardCollection, formModel: NoteCardFormModel) {
        formModel.selectedCollection = collection
        formModel.isSelectingCollection = false
    }
    
    func handleNoteCardFormRelationshipSelected(_ relationship: NoteCard, formModel: NoteCardFormModel) {
        formModel.objectWillChange.send()
        if formModel.selectedRelationships.contains(relationship) {
            formModel.selectedRelationships.remove(relationship)
        } else {
            formModel.selectedRelationships.insert(relationship)
        }
    }
    
    func handleNoteCardFormTagSelected(_ tag: Tag, formModel: NoteCardFormModel) {
        if formModel.selectedTags.contains(tag) {
            formModel.selectedTags.remove(tag)
        } else {
            formModel.selectedTags.insert(tag)
        }
    }
    
    func handleNoteCardCUDResult(_ result: ObjectCUDResult<NoteCard>) {
        switch result {
        case .created(_, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchCurrentNoteCards()
            viewModel.updateSnapshot(with: appState.currenNoteCards, animated: true)
            sheet = nil
            
        case .updated(let noteCard, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            if noteCard.collection?.uuid != collection.uuid {
                appState.fetchCurrentNoteCards()
                viewModel.updateSnapshot(with: appState.currenNoteCards, animated: true)
            }
            sheet = nil
            
        case .failed: // TODO: show alert if needed
            sheet = nil
            
        case .deleted:
            fatalError("🧨 hmm... tried to delete object in commitCreateNoteCard method 🧨")
        }
    }
}


struct HomeNoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        HomeNoteCardView(viewModel: .init(), collection: .sample)
    }
}
