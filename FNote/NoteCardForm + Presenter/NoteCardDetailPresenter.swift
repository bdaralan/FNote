//
//  NoteCardQuickDetailPresenter.swift
//  FNote
//
//  Created by Dara Beng on 5/9/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit


struct NoteCardDetailPresenter: View {
    
    @ObservedObject var viewModel: NoteCardDetailPresenterModel
    
    @State private var sheet = BDPresentationItem<Sheet>()
    
    @State private var noteTextViewModel = ModalTextViewModel()
    
    @State private var relationshipViewModel: NoteCardCollectionViewModel?
    
    @State private var noteCardFormModel: NoteCardFormModel?
    
    @State private var tagViewModel: TagCollectionViewModel?
    
    
    var body: some View {
        Color.clear
            .sheet(item: $sheet.current, onDismiss: presentationSheetDismissed, content: presentationSheet)
            .onReceive(viewModel.$sheet, perform: presentSheet)
    }
}


// MARK: - Sheet

extension NoteCardDetailPresenter {
    
    enum Sheet: BDPresentationSheetItem {
        case relationship(NoteCard)
        case tag(NoteCard)
        case note(NoteCard)
        case edit(noteCard: NoteCard, completion: () -> Void)
        case createNoteCard(for: NoteCardCollection, completion: () -> Void)
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
            
        case .relationship:
            let done = { self.sheet.dismiss() }
            let label = { Text("Done").bold() }
            let doneNavItem = Button(action: done, label: label)
            return NavigationView {
                CollectionViewWrapper(viewModel: relationshipViewModel!)
                    .edgesIgnoringSafeArea(.all)
                    .navigationBarTitle("Links", displayMode: .inline)
                    .navigationBarItems(trailing: doneNavItem)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .eraseToAnyView()
            
        case .tag:
            let done = { self.sheet.dismiss() }
            let label = { Text("Done").bold() }
            let doneNavItem = Button(action: done, label: label)
            return NavigationView {
                NoteCardFormTagSelectionView(viewModel: tagViewModel!)
                    .navigationBarTitle("Tags", displayMode: .inline)
                    .navigationBarItems(trailing: doneNavItem)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .eraseToAnyView()
            
        case .note:
            return ModalTextView(viewModel: $noteTextViewModel)
                .eraseToAnyView()
            
        case .edit, .createNoteCard:
            return NoteCardForm(viewModel: noteCardFormModel!)
                .eraseToAnyView()
        }
    }
    
    func presentSheet(_ sheet: Sheet?) {
        guard let sheet = sheet else {
            self.sheet.dismiss()
            return
        }
        
        switch sheet {
        
        case let .relationship(noteCard):
            let model = NoteCardCollectionViewModel()
            model.cellStyle = .short
            model.contextMenus = [.copyNative]
            
            model.onContextMenuSelected = { menu, noteCard in
                guard menu == .copyNative else { return }
                UIPasteboard.general.string = noteCard.native
            }
            
            model.onNoteCardSelected = { noteCard in
                // setup cards to display
                // clear current bordered cells
                // show the cards to display
                self.prepareNoteCardRelationships(for: model, with: noteCard)
                model.reloadedVisibleCells()
                model.updateSnapshot(animated: true)
            }
            
            prepareNoteCardRelationships(for: model, with: noteCard)
            relationshipViewModel = model
        
        case let .tag(noteCard):
            let model = TagCollectionViewModel()
            model.tags = noteCard.tags.sortedByName()
            tagViewModel = model
        
        case let .note(noteCard):
            noteTextViewModel = .init()
            noteTextViewModel.renderMarkdown = viewModel.renderMarkdown
            noteTextViewModel.renderSoftBreak = viewModel.renderSoftBreak
            noteTextViewModel.disableEditing = true
            noteTextViewModel.title = "Note"
            noteTextViewModel.text = noteCard.note
            
            noteTextViewModel.onCommit = {
                self.sheet.dismiss()
            }
            
        case let .edit(noteCard, completion):
            setupEditNoteCard(noteCard: noteCard, completion: completion)
            
        case let .createNoteCard(collection, completion):
            setupCreateNoteCard(collection: collection, completion: completion)
        }
        
        self.sheet.present(sheet)
    }
    
    func presentationSheetDismissed() {
        noteCardFormModel = nil
        relationshipViewModel = nil
        tagViewModel = nil
    }
}


// MARK: - Create Note Card

extension NoteCardDetailPresenter {
    
    func setupCreateNoteCard(collection: NoteCardCollection, completion: @escaping () -> Void) {
        let formModel = NoteCardFormModel(collection: collection, noteCard: nil)
        noteCardFormModel = formModel
        
        formModel.commitTitle = "Create"
        formModel.navigationTitle = "New Card"
        formModel.presentWithKeyboard = true
        
        formModel.selectableCollections = viewModel.appState.collections
        formModel.selectableRelationships = viewModel.appState.currentNoteCards
        formModel.selectableTags = viewModel.appState.tags
        formModel.relationshipSelectedCollection = collection
        
        setupHandlers(for: formModel)
        
        formModel.onCommit = {
            guard let collection = formModel.selectedCollection else {
                fatalError("🧨 attempt to create note card without collection 🧨")
            }
            
            // create note card
            let context = self.viewModel.appState.parentContext
            var modifier = ObjectModifier<NoteCard>(.create(in: context))
            modifier.native = formModel.native
            modifier.translation = formModel.translation
            modifier.formality = formModel.selectedFormality
            modifier.isFavorite = formModel.isFavorite
            modifier.note = formModel.note
            modifier.setCollection(collection)
            modifier.setRelationships(formModel.selectedRelationships)
            modifier.setTags(formModel.selectedTags)
            modifier.save()
            
            // dismiss & call completion
            self.sheet.dismiss()
            completion()
        }
    }
}


// MARK: - Edit Note Card

extension NoteCardDetailPresenter {
    
    func setupEditNoteCard(noteCard: NoteCard, completion: @escaping () -> Void) {
        guard let collection = noteCard.collection else {
            fatalError("🧨 attempt to edit note card without collection 🧨")
        }
        
        let formModel = NoteCardFormModel(collection: collection, noteCard: noteCard)
        noteCardFormModel = formModel
        
        formModel.update(with: noteCard)
        formModel.commitTitle = "Update"
        formModel.navigationTitle = "Card Detail"
        formModel.nativePlaceholder = noteCard.native
        formModel.translationPlaceholder = noteCard.translation
        
        formModel.selectedCollection = collection
        formModel.selectableCollections = viewModel.appState.collections
        formModel.selectableRelationships = viewModel.appState.currentNoteCards
        formModel.selectableTags = viewModel.appState.tags
        formModel.relationshipSelectedCollection = collection
        
        setupHandlers(for: formModel)
        
        formModel.onCommit = {
            guard let collection = formModel.selectedCollection else {
                fatalError("🧨 attempt to edit note card without collection 🧨")
            }
            
            // update note card
            var modifier = ObjectModifier<NoteCard>(.update(noteCard))
            modifier.native = formModel.native
            modifier.translation = formModel.translation
            modifier.formality = formModel.selectedFormality
            modifier.isFavorite = formModel.isFavorite
            modifier.note = formModel.note
            modifier.setCollection(collection)
            modifier.setRelationships(formModel.selectedRelationships)
            modifier.setTags(formModel.selectedTags)
            modifier.save()
            
            // dismiss & call completion
            self.sheet.dismiss()
            completion()
        }
        
        formModel.onCollectionSelected = { collection in
            self.handleCollectionSelected(collection, for: formModel)
        }
        
        formModel.onRelationshipSelected = { relationship in
            self.handleRelationshipSelected(relationship, for: formModel)
        }
        
        formModel.onRelationshipCollectionSelected = { collection in
            self.handleRelationshipCollectionSelected(collection, for: formModel)
        }
        
        formModel.onTagSelected = { tag in
            self.handleTagSelected(tag, for: formModel)
        }
        
        formModel.onCreateTag = { name in
            self.handleCreateTag(name: name, for: formModel)
        }
    }
}


// MARK: - Create & Edit Form Helper

extension NoteCardDetailPresenter {
    
    func setupHandlers(for formModel: NoteCardFormModel) {
        formModel.onCancel = {
            self.sheet.dismiss()
        }
        
        formModel.onCollectionSelected = { collection in
            self.handleCollectionSelected(collection, for: formModel)
        }
        
        formModel.onRelationshipSelected = { relationship in
            self.handleRelationshipSelected(relationship, for: formModel)
        }
        
        formModel.onRelationshipCollectionSelected = { collection in
            self.handleRelationshipCollectionSelected(collection, for: formModel)
        }
        
        formModel.onTagSelected = { tag in
            self.handleTagSelected(tag, for: formModel)
        }
        
        formModel.onCreateTag = { name in
            self.handleCreateTag(name: name, for: formModel)
        }
    }
    
    func handleCollectionSelected(_ collection: NoteCardCollection, for formModel: NoteCardFormModel) {
        formModel.selectedCollection = collection
        formModel.relationshipSelectedCollection = collection
        formModel.selectableRelationships = collection.noteCards.sorted(by: { $0.translation < $1.translation })
        formModel.isSelectingCollection = false
    }
    
    func handleRelationshipSelected(_ relationship: NoteCard, for formModel: NoteCardFormModel) {
        if formModel.selectedRelationships.contains(relationship) {
            formModel.selectedRelationships.remove(relationship)
        } else {
            formModel.selectedRelationships.insert(relationship)
        }
    }
    
    func handleRelationshipCollectionSelected(_ collection: NoteCardCollection, for formModel: NoteCardFormModel) {
        formModel.selectableRelationships = collection.noteCards.sorted(by: { $0.translation < $1.translation })
        formModel.relationshipSelectedCollection = collection
    }
    
    func handleTagSelected(_ tag: Tag, for formModel: NoteCardFormModel) {
        if formModel.selectedTags.contains(tag) {
            formModel.selectedTags.remove(tag)
        } else {
            formModel.selectedTags.insert(tag)
        }
    }
    
    func handleCreateTag(name: String, for formModel: NoteCardFormModel) -> Tag? {
        let appState = viewModel.appState
        
        if appState.isDuplicateTagName(name) {
            return nil
        }
        
        let parentContext = appState.parentContext
        var tagModifier = ObjectModifier<Tag>(.create(in: parentContext))
        tagModifier.name = name
        tagModifier.save()
        
        appState.fetchTags()
        
        let newTag = tagModifier.modifiedObject.get(from: parentContext)
        formModel.selectableTags.insert(newTag, at: 0)
        formModel.selectedTags.insert(newTag)
        
        return newTag
    }
    
    func prepareNoteCardRelationships(for model: NoteCardCollectionViewModel, with noteCard: NoteCard) {
        let relationships = noteCard.relationships.sorted(by: { $0.translation < $1.translation })
        model.noteCards = [noteCard] + relationships
        model.borderedNoteCardIDs = [noteCard.uuid]
        model.ignoreSelectionNoteCardIDs = [noteCard.uuid]
    }
}


struct NoteCardDetailPresenter_Previews: PreviewProvider {
    static let appState = AppState(parentContext: .sample)
    static let viewModel = NoteCardDetailPresenterModel(appState: appState)
    static var previews: some View {
        NoteCardDetailPresenter(viewModel: viewModel)
    }
}
