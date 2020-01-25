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
    @State private var relationshipViewModel: NoteCardCollectionViewModel?
    @State private var tagViewModel: NoteCardFormModel?
    @State private var textViewModel = ModalTextViewModel()
    
    @State private var noteCardToDelete: NoteCard?
    
    
    var body: some View {
        NavigationView {
            CollectionViewWrapper(viewModel: viewModel)
                .navigationBarTitle(Text(collection.name), displayMode: .large)
                .navigationBarItems(trailing: createNoteCardNavItem)
                .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet, onDismiss: presentationSheetDismissed, content: presentationSheet)
        .alert(item: $noteCardToDelete, content: deleteNoteCardAlert)
        .onAppear(perform: setupOnAppear)
    }
}


// MARK: - Sheet & Alert

extension HomeNoteCardView {
    
    enum Sheet: Identifiable {
        var id: Self { self }
        case noteCardForm
        case noteCardRelationship
        case noteCardTag
        case noteCardNote
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .noteCardForm:
            return NoteCardForm(viewModel: noteCardFormModel!)
                .eraseToAnyView()
            
        case .noteCardRelationship:
            let doneNavItem = Button("Done", action: { self.sheet = nil })
            return NavigationView {
                NoteCardFormRelationshipSelectionView(viewModel: relationshipViewModel!)
                    .navigationBarTitle("Relationships", displayMode: .inline)
                    .navigationBarItems(trailing: doneNavItem)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .eraseToAnyView()
            
        case .noteCardTag:
            let doneNavItem = Button("Done", action: { self.sheet = nil })
            return NavigationView {
                NoteCardFormTagSelectionView(
                    formModel: tagViewModel!,
                    showSelectedHeader: false,
                    showUnselectedSection: false
                )
                    .navigationBarTitle("Tags", displayMode: .inline)
                    .navigationBarItems(trailing: doneNavItem)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .eraseToAnyView()
            
        case .noteCardNote:
            return ModalTextView(viewModel: $textViewModel)
                .eraseToAnyView()
        }
    }
    
    func presentationSheetDismissed() {
        noteCardFormModel = nil
        relationshipViewModel = nil
        tagViewModel = nil
    }
}


// MARK: - On Appear

extension HomeNoteCardView {
    
    func setupOnAppear() {
        viewModel.contextMenus = [.delete]
        viewModel.noteCards = appState.currenNoteCards
        viewModel.onNoteCardSelected = beginEditNoteCard
        viewModel.onNoteCardQuickButtonTapped = handleNoteCardQuickButtonTapped
        viewModel.onContextMenuSelected = handleContextMenuSelected
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
        guard let createRequest = formModel.createNoteCardCUDRequest() else { return }
        let result = appState.createNoteCard(with: createRequest)
        handleNoteCardCUDResult(result)
    }
    
    func cancelCreateNoteCard() {
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
        sheet = nil
    }
    
    func commitEditNoteCard(_ noteCard: NoteCard) {
        guard let formModel = noteCardFormModel else { return }
        guard let request = formModel.createNoteCardCUDRequest() else { return }
        let result = appState.updateNoteCard(noteCard, with: request)
        handleNoteCardCUDResult(result)
    }
}


// MARK: - Delete Note Card

extension HomeNoteCardView {
    
    func deleteNoteCardAlert(_ noteCard: NoteCard) -> Alert {
        Alert.DeleteNoteCard(noteCard, onCancel: cancelDeleteNoteCard, onDelete: commitDeleteNoteCard)
    }
    
    func cancelDeleteNoteCard() {
        noteCardToDelete = nil
    }
    
    func commitDeleteNoteCard() {
        guard let noteCardToDelete = noteCardToDelete else { return }
        let result = appState.deleteObject(noteCardToDelete)
        switch result {
        case .deleted(let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchCurrentNoteCards()
            viewModel.noteCards = appState.currenNoteCards
            viewModel.updateSnapshot(animated: true)
            
        case .failed: // TODO: inform user if needed
            break
            
        case .created, .updated:
            fatalError("🧨 hmm... tried to \(result) object in commitDeleteNoteCard method 🧨")
        }
    }
}


// MARK: - Note Card Quick Button

extension HomeNoteCardView {
    
    func handleNoteCardQuickButtonTapped(_ button: NoteCardCell.QuickButtonType, noteCard: NoteCard) {
        switch button {
        case .relationship:
            relationshipViewModel = .init()
            let noteCards = noteCard.relationships.sorted(by: { $0.translation < $1.translation })
            relationshipViewModel?.noteCards = noteCards
            relationshipViewModel?.cellStyle = .short
            relationshipViewModel?.onNoteCardSelected = { print($0.native) }
            sheet = .noteCardRelationship
        
        case .tag:
            tagViewModel = .init(collection: collection)
            tagViewModel?.selectedTags = noteCard.tags
            sheet = .noteCardTag
        
        case .favorite:
            noteCard.isFavorited.toggle()
            noteCard.managedObjectContext?.quickSave()
        
        case .note:
            textViewModel = .init()
            textViewModel.renderMarkdown = true
            textViewModel.disableEditing = true
            textViewModel.title = "Note"
            textViewModel.text = noteCard.note
            textViewModel.onCommit = {
                self.sheet = nil
            }
            sheet = .noteCardNote
        }
    }
}


// MARK: - Note Card Context Menu

extension HomeNoteCardView {
    
    func handleContextMenuSelected(_ menu: NoteCardCell.ContextMenu, noteCard: NoteCard) {
        switch menu {
        case .delete:
            noteCardToDelete = noteCard
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
            viewModel.noteCards = appState.currenNoteCards
            viewModel.updateSnapshot(animated: true)
            sheet = nil
            
        case .updated(let noteCard, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            if noteCard.collection?.uuid != collection.uuid {
                appState.fetchCurrentNoteCards()
                viewModel.noteCards = appState.currenNoteCards
                viewModel.updateSnapshot(animated: true)
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
