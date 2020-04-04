//
//  NoteCardForm.swift
//  FNote
//
//  Created by Dara Beng on 2/2/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardForm: View {
    
    @ObservedObject var viewModel: NoteCardFormModel
    
    @State private var sheet: Sheet?
    @State private var modalTextViewModel = ModalTextViewModel()
    
    @State private var showSelectRelationshipCollection = false
    let selectRelationshipCollectionViewModel = NoteCardCollectionCollectionViewModel()
    
    @State private var selectCollectionViewModel = NoteCardCollectionCollectionViewModel()
    @State private var selectTagViewModel = TagCollectionViewModel()
    @State private var selectRelationshipViewModel = NoteCardCollectionViewModel()
    @State private var relationshipCurrentSearchText = ""
    
    @State private var translationTextField: UITextField?
    
    let iconSize = CGSize(width: 25, height: 20)
    
    
    var body: some View {
        NavigationView {
            NoteCardFormControllerWrapper(viewModel: viewModel, onRowSelected: handleRowSelected)
                .navigationBarItems(leading: cancelNavItem, trailing: commitNavItem)
                .navigationBarTitle(Text(viewModel.presentingTitle), displayMode: .inline)
                .edgesIgnoringSafeArea(.bottom)
                .background(selectCollectionNavigationLink)
                .background(selectRelationshipNavigationLink)
                .background(selectTagNavigationLink)
                .onReceive(viewModel.$isSelectingCollection, perform: handleOnReceiveSelectingCollection)
                .onReceive(viewModel.$isSelectingRelationship, perform: handleOnReceiveSelectingRelationship)
                .onReceive(viewModel.$isSelectingTag, perform: handleOnReceiveSelectingTag)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet, onDismiss: handleSheetDismissed, content: presentationSheet)
    }
}


// MARK: - Navigation Items

extension NoteCardForm {
    
    var cancelNavItem: some View {
        Button("Cancel", action: viewModel.onCancel ?? {})
            .disabled(viewModel.onCancel == nil)
    }
    
    var commitNavItem: some View {
        Button(action: viewModel.onCommit ?? {}) {
            Text(viewModel.commitTitle).bold()
        }
        .disabled(viewModel.onCommit == nil || !viewModel.canCommit)
    }
}


// MARK: - Sheet

extension NoteCardForm {
    
    enum Sheet: Identifiable {
        var id: Self { self }
        case note
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .note:
            return ModalTextView(viewModel: $modalTextViewModel)
        }
    }
    
    func handleSheetDismissed() {
        if modalTextViewModel.onCommit != nil {
            viewModel.note = modalTextViewModel.text
        }
    }
}


// MARK: - Navigation Link

extension NoteCardForm {
    
    func handleRowSelected(kind: NoteCardFormSection.Row) {
        switch kind {
        case .native, .translation, .formality, .favorite: break
        case .collection: beginSelectCollection()
        case .relationship: beginSelectRelationship()
        case .tag: beginSelectTag()
        case .note: beginEditNote()
        }
    }
    
    var selectCollectionNavigationLink: some View {
        NavigationLink(
            destination: NoteCardFormCollectionSelectionView(viewModel: selectCollectionViewModel),
            isActive: $viewModel.isSelectingCollection,
            label: EmptyView.init
        )
    }
    
    var selectTagNavigationLink: some View {
        NavigationLink(
            destination: NoteCardFormTagSelectionView(viewModel: selectTagViewModel, onCreateTag: handleCreateTag),
            isActive: $viewModel.isSelectingTag,
            label: EmptyView.init
        )
    }
    
    var selectRelationshipNavigationLink: some View {
        let done = { self.showSelectRelationshipCollection = false }
        let doneLabel = { Text("Done").bold() }
        let doneNavItem = Button(action: done, label: doneLabel)
        
        let chooseCollectionView = NavigationView {
            CollectionViewWrapper(viewModel: selectRelationshipCollectionViewModel)
                .navigationBarTitle("Link Collection", displayMode: .inline)
                .navigationBarItems(trailing: doneNavItem)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
        let chooseCollectionNavItem = NavigationBarButton(
            imageName: "rectangle.stack",
            action: beginChooseRelationshipCollection
        )
        
        let destinationView = NoteCardFormRelationshipSelectionView(viewModel: selectRelationshipViewModel)
            .navigationBarTitle(viewModel.relationshipSelectedCollection?.name ?? "???")
            .navigationBarItems(trailing: chooseCollectionNavItem)
            .sheet(isPresented: $showSelectRelationshipCollection, content: { chooseCollectionView })
        
        return NavigationLink(
            destination: destinationView,
            isActive: $viewModel.isSelectingRelationship,
            label: EmptyView.init
        )
    }
}


// MARK: - Note

extension NoteCardForm {
    
    func beginEditNote() {
        modalTextViewModel = .init()
        modalTextViewModel.title = "Note"
        modalTextViewModel.text = viewModel.note
        
        modalTextViewModel.isFirstResponder = true
        modalTextViewModel.onCommit = commitEditNote
        
        sheet = .note
    }
    
    func commitEditNote() {
        viewModel.note = modalTextViewModel.text
        modalTextViewModel.isFirstResponder = false
        sheet = nil
    }
}


// MARK: - Collection Selection

extension NoteCardForm {
    
    func beginSelectCollection() {
        selectCollectionViewModel.collections = viewModel.selectableCollections
        
        if let collection = viewModel.selectedCollection {
            selectCollectionViewModel.borderedCollectionIDs = [collection.uuid]
            selectCollectionViewModel.ignoreSelectionCollectionIDs = [collection.uuid]
        }
        
        selectCollectionViewModel.onCollectionSelected = { collection in
            self.viewModel.onCollectionSelected?(collection)
            self.viewModel.isSelectingCollection = false
        }
        
        viewModel.isSelectingCollection = true
    }
    
    func handleOnReceiveSelectingCollection(_ isSelecting: Bool) {
        guard !isSelecting else { return }
        selectCollectionViewModel = .init()
    }
}


// MARK: - Relationship Selection

extension NoteCardForm {
    
    func beginChooseRelationshipCollection() {
        selectRelationshipCollectionViewModel.collections = viewModel.selectableCollections
        
        if let collection = viewModel.relationshipSelectedCollection {
            selectRelationshipCollectionViewModel.disabledCollectionIDs = [collection.uuid]
        }
        
        selectRelationshipCollectionViewModel.onCollectionSelected = { collection in
            self.viewModel.onRelationshipCollectionSelected?(collection)
            
            self.selectRelationshipCollectionViewModel.disabledCollectionIDs = [collection.uuid]
            self.selectRelationshipCollectionViewModel.updateSnapshot(animated: false)
            
            self.selectRelationshipViewModel.noteCards = self.viewModel.selectableRelationships
            self.selectRelationshipViewModel.updateSnapshot(animated: false)
            
            self.showSelectRelationshipCollection = false
        }
        
        showSelectRelationshipCollection = true
    }
    
    func beginSelectRelationship() {
        selectRelationshipViewModel.noteCards = viewModel.selectableRelationships
        selectRelationshipViewModel.cellStyle = .short
        
        viewModel.selectedRelationships.forEach { noteCard in
            selectRelationshipViewModel.borderedNoteCardIDs.insert(noteCard.uuid)
        }
        
        if let noteCard = viewModel.selectedNoteCard {
            selectRelationshipViewModel.disableNoteCardIDs.insert(noteCard.uuid)
        }
        
        selectRelationshipViewModel.onNoteCardSelected = handleRelationshipNoteCardSelected
        
        // setup search
        if viewModel.relationshipSelectedCollection != nil {
            selectRelationshipViewModel.onSearchTextDebounced = handleRelationshipSearchTextDebounced
            selectRelationshipViewModel.onSearchNoteActiveChanged = handleRelationshipSearchNoteActiveChanged
            selectRelationshipViewModel.onSearchCancel = handleRelationshipSearchCancel
        }
        
        viewModel.isSelectingRelationship = true
    }
    
    func handleOnReceiveSelectingRelationship(_ isSelecting: Bool) {
        guard !isSelecting else { return }
        selectRelationshipViewModel = .init()
    }
    
    func handleRelationshipNoteCardSelected(_ noteCard: NoteCard) {
        if selectRelationshipViewModel.borderedNoteCardIDs.contains(noteCard.uuid) {
            selectRelationshipViewModel.borderedNoteCardIDs.remove(noteCard.uuid)
        } else {
            selectRelationshipViewModel.borderedNoteCardIDs.insert(noteCard.uuid)
        }
        viewModel.onRelationshipSelected?(noteCard)
    }
    
    func handleRelationshipSearchTextDebounced(_ searchText: String) {
        relationshipCurrentSearchText = searchText
        
        guard !searchText.trimmed().isEmpty else {
            selectRelationshipViewModel.noteCards = viewModel.selectableRelationships
            selectRelationshipViewModel.updateSnapshot(animated: true)
            return
        }
        
        let searchResults = viewModel.selectableRelationships.filter { noteCard in
            let matchNative = noteCard.native.range(of: searchText, options: .caseInsensitive) != nil
            let matchTranslation = noteCard.translation.range(of: searchText, options: .caseInsensitive) != nil
            if selectRelationshipViewModel.isSearchNoteActive {
                let matchNote = noteCard.note.range(of: searchText, options: .caseInsensitive) != nil
                return matchNote || matchTranslation || matchNote
            } else {
                return matchNative || matchTranslation
            }
        }
        
        selectRelationshipViewModel.noteCards = searchResults
        selectRelationshipViewModel.updateSnapshot(animated: true)
    }
    
    func handleRelationshipSearchNoteActiveChanged(_ isActive: Bool) {
        handleRelationshipSearchTextDebounced(relationshipCurrentSearchText)
    }
    
    func handleRelationshipSearchCancel() {
        selectRelationshipViewModel.noteCards = viewModel.selectableRelationships
        selectRelationshipViewModel.updateSnapshot(animated: true)
    }
}


// MARK: - Tag Selection

extension NoteCardForm {
    
    func beginSelectTag() {
        selectTagViewModel.tags = viewModel.selectableTags
        
        for tag in viewModel.selectedTags {
            selectTagViewModel.borderedTagIDs.insert(tag.uuid)
        }
        
        selectTagViewModel.onTagSelected = handleTagViewTagSelected
        
        viewModel.isSelectingTag = true
    }
    
    func handleOnReceiveSelectingTag(_ isSelecting: Bool) {
        guard !isSelecting else { return }
        selectTagViewModel = .init()
    }
    
    func handleTagViewTagSelected(_ tag: Tag) {
        if selectTagViewModel.borderedTagIDs.contains(tag.uuid) {
            selectTagViewModel.borderedTagIDs.remove(tag.uuid)
        } else {
            selectTagViewModel.borderedTagIDs.insert(tag.uuid)
        }
        viewModel.onTagSelected?(tag)
    }
    
    func handleCreateTag(withName name: String) -> Bool {
        if let tag = viewModel.onCreateTag?(name) {
            selectTagViewModel.tags.insert(tag, at: 0)
            selectTagViewModel.borderedTagIDs.insert(tag.uuid)
            selectTagViewModel.updateSnapshot(animated: true)
            return true
        }
        return false
    }
}


// MARK: - Setup Text Field

extension NoteCardForm {
    
    func configureNativeTextField(_ textField: UITextField) {
        textField.font = .preferredFont(forTextStyle: .headline)
        textField.returnKeyType = .next
    }
    
    func configureTranslationTextField(_ textField: UITextField) {
        translationTextField = textField
        textField.font = .preferredFont(forTextStyle: .body)
    }
}


struct NoteCardForm_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NoteCardForm(viewModel: .init()).colorScheme(.light)
            NoteCardForm(viewModel: .init()).colorScheme(.dark)
        }
    }
}
