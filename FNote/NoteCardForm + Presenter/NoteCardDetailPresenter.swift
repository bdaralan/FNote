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
    
    @State private var collectionViewModel: NoteCardCollectionCollectionViewModel?
    
    
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
        case create(noteCardIn: NoteCardCollection, completion: () -> Void)
        case allCollections(title: String, selectedID: String?, onSelected: ((NoteCardCollection) -> Void)?)
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
            
        case .relationship:
            return NavigationView {
                CollectionViewWrapper(viewModel: relationshipViewModel!)
                    .edgesIgnoringSafeArea(.all)
                    .navigationBarTitle("Links", displayMode: .inline)
                    .navigationBarItems(trailing: dismissSheetNavItem())
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .eraseToAnyView()
            
        case .tag:
            return NavigationView {
                NoteCardFormTagSelectionView(viewModel: tagViewModel!)
                    .navigationBarTitle("Tags", displayMode: .inline)
                    .navigationBarItems(trailing: dismissSheetNavItem())
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .eraseToAnyView()
            
        case .note:
            return ModalTextView(viewModel: $noteTextViewModel)
                .eraseToAnyView()
            
        case .edit, .create:
            return NoteCardForm(viewModel: noteCardFormModel!)
                .eraseToAnyView()
            
        case .allCollections(let title, _, _):
            return NavigationView {
                CollectionViewWrapper(viewModel: collectionViewModel!)
                    .navigationBarTitle(Text(title), displayMode: .inline)
                    .navigationBarItems(trailing: dismissSheetNavItem())
            }
            .eraseToAnyView()
        }
    }
    
    func dismissSheetNavItem() -> some View {
        let action = { self.sheet.dismiss() }
        let label = { Text("Done").bold() }
        return Button(action: action, label: label)
    }
    
    func presentSheet(_ sheet: Sheet?) {
        guard let sheet = sheet else {
            self.sheet.dismiss()
            return
        }
        
        switch sheet {
        
        case let .relationship(noteCard):
            setupRelationshipModel(for: noteCard)
        
        case let .tag(noteCard):
            setupTagModel(for: noteCard)
        
        case let .note(noteCard):
            setupNoteTextViewModel(for: noteCard)
            
        case let .edit(noteCard, completion):
            setupNoteCardEditFormModel(noteCard: noteCard, completion: completion)
            
        case let .create(inCollection, completion):
            setupNoteCardCreateFormModel(collection: inCollection, completion: completion)
            
        case let .allCollections(_, selectedID, onSelected):
            setupAllCollectionViewModel(selectedID: selectedID, onSelected: onSelected)
        }
        
        self.sheet.present(sheet)
    }
    
    func presentationSheetDismissed() {
        noteCardFormModel = nil
        relationshipViewModel = nil
        tagViewModel = nil
        collectionViewModel = nil
    }
}


// MARK: - Collections

extension NoteCardDetailPresenter {
    
    func setupAllCollectionViewModel(selectedID: String?, onSelected: ((NoteCardCollection) -> Void)?) {
        let model = NoteCardCollectionCollectionViewModel()
        collectionViewModel = model
        
        model.collections = viewModel.appState.collections
        
        model.onCollectionSelected = { collection in
            model.borderedCollectionIDs = [collection.uuid]
            model.reloadVisibleCells()
            onSelected?(collection)
        }
        
        if let collectionID = selectedID {
            model.borderedCollectionIDs = [collectionID]
        }
    }
}


// MARK: - View Note Card

extension NoteCardDetailPresenter {
    
    func setupRelationshipModel(for noteCard: NoteCard) {
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
    }
    
    func setupNoteTextViewModel(for noteCard: NoteCard) {
        noteTextViewModel = .init()
        noteTextViewModel.renderMarkdown = viewModel.renderMarkdown
        noteTextViewModel.renderSoftBreak = viewModel.renderSoftBreak
        noteTextViewModel.disableEditing = true
        noteTextViewModel.title = "Note"
        noteTextViewModel.text = noteCard.note
        
        noteTextViewModel.onCommit = {
            self.sheet.dismiss()
        }
    }
    
    func setupTagModel(for noteCard: NoteCard) {
        let model = TagCollectionViewModel()
        model.tags = noteCard.tags.sorted(by: { $0.name < $1.name })
        tagViewModel = model
    }
}


// MARK: - Create Note Card

extension NoteCardDetailPresenter {
    
    func setupNoteCardCreateFormModel(collection: NoteCardCollection, completion: @escaping () -> Void) {
        let formModel = NoteCardFormModel(collection: collection, noteCard: nil)
        noteCardFormModel = formModel
        
        formModel.commitTitle = "Create"
        formModel.navigationTitle = "New Card"
        formModel.presentWithKeyboard = true
        formModel.showGeneralKeyboardUsage = viewModel.appState.preference.showGeneralKeyboardUsage
        
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
            modifier.favorited = formModel.favorited
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
    
    func setupNoteCardEditFormModel(noteCard: NoteCard, completion: @escaping () -> Void) {
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
        formModel.presentWithKeyboard = false
        formModel.showGeneralKeyboardUsage = viewModel.appState.preference.showGeneralKeyboardUsage
        
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
            modifier.favorited = formModel.favorited
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
        let relationships = noteCard.linker.targets.sorted(by: { $0.translation < $1.translation })
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
