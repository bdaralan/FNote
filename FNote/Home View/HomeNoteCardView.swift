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
    @EnvironmentObject var userPreference: UserPreference
    
    var viewModel: NoteCardCollectionViewModel
    
    var collection: NoteCardCollection
    
    var collectionView: UICollectionView
    
    @State private var sheet: Sheet?
    @State private var showSortOption = false

    @State private var noteCardFormModel: NoteCardFormModel?
    @State private var relationshipViewModel: NoteCardCollectionViewModel?
    @State private var tagViewModel: TagCollectionViewModel?
    @State private var textViewModel = ModalTextViewModel()
    
    @State private var noteCardToDelete: NoteCard?
    
    @State private var searchFetchController: NSFetchedResultsController<NoteCard>?
    @State private var currentSearchText = ""
    
    var iPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    
    var body: some View {
        NavigationView {
            CollectionViewWrapper(viewModel: viewModel, collectionView: collectionView)
                .navigationBarTitle(Text(collection.name), displayMode: .large)
                .navigationBarItems(trailing: trailingNavItems)
                .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet, onDismiss: presentationSheetDismissed, content: presentationSheet)
        .alert(item: $noteCardToDelete, content: deleteNoteCardAlert)
        .actionSheet(isPresented: iPad ? .constant(false) : $showSortOption, content: presentationActionSheet)
        .onReceive(appState.currentNoteCardsWillChange, perform: handleOnReceiveCurrentNotesCardWillChange)
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
            let done = { self.sheet = nil }
            let label = { Text("Done").bold() }
            let doneNavItem = Button(action: done, label: label)
            return NavigationView {
                NoteCardFormRelationshipSelectionView(viewModel: relationshipViewModel!)
                    .navigationBarTitle("Links", displayMode: .inline)
                    .navigationBarItems(trailing: doneNavItem)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .eraseToAnyView()
            
        case .noteCardTag:
            let done = { self.sheet = nil }
            let label = { Text("Done").bold() }
            let doneNavItem = Button(action: done, label: label)
            return NavigationView {
                NoteCardFormTagSelectionView(viewModel: tagViewModel!)
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
    
    func presentationActionSheet() -> ActionSheet {
        let nativeAscending = { self.setNoteCardSortOption(.native, ascending: true) }
        let nativeDescending = { self.setNoteCardSortOption(.native, ascending: false) }
        let translationAscending = { self.setNoteCardSortOption(.translation, ascending: true) }
        let translationDescending = { self.setNoteCardSortOption(.translation, ascending: false) }
        return ActionSheet(title: Text("Sort By"), message: nil, buttons: [
            .default(Text("Native Ascending"), action: nativeAscending),
            .default(Text("Native Descending"), action: nativeDescending),
            .default(Text("Translation Ascending"), action: translationAscending),
            .default(Text("Translation Descending"), action: translationDescending),
            .cancel()
        ])
    }
    
    func setNoteCardSortOption(_ option: NoteCardSortOption, ascending: Bool) {
        let currentOption = appState.noteCardSortOption
        let currentAscending = appState.noteCardSortOptionAscending
        
        guard option != currentOption || ascending != currentAscending else { return }
        userPreference.objectWillChange.send()
        userPreference.noteCardSortOption = option
        userPreference.noteCardSortOptionAscending = ascending
        appState.noteCardSortOption = option
        appState.noteCardSortOptionAscending = ascending
        appState.fetchCurrentNoteCards()
        viewModel.noteCards = appState.currenNoteCards
        viewModel.updateSnapshot(animated: true)
    }
}


// MARK: - On Appear

extension HomeNoteCardView {
    
    func setupOnAppear() {
        viewModel.contextMenus = [.copyNative, .delete]
        viewModel.noteCards = appState.currenNoteCards
        viewModel.onNoteCardSelected = beginEditNoteCard
        viewModel.onNoteCardQuickButtonTapped = handleNoteCardQuickButtonTapped
        viewModel.onContextMenuSelected = handleContextMenuSelected
        viewModel.onSearchTextDebounced = handleSearchTextDebounced
        viewModel.onSearchCancel = handleSearchCancel
        viewModel.onSearchNoteActiveChanged = handleSearchNoteActiveChanged
        viewModel.updateSnapshot(animated: false)
    }
}


// MARK: - Search

extension HomeNoteCardView {
    
    func handleSearchTextDebounced(_ searchText: String) {
        currentSearchText = searchText
        
        guard !searchText.trimmed().isEmpty else {
            viewModel.noteCards = appState.currenNoteCards
            viewModel.updateSnapshot(animated: true)
            searchFetchController = nil
            return
        }
        
        if searchFetchController == nil {
            searchFetchController = .init(
                fetchRequest: NoteCard.requestNone(),
                managedObjectContext: appState.parentContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        }
        
        let isNoteActive = viewModel.isSearchNoteActive
        
        let request = NoteCard.requestNoteCards(
            forCollectionUUID: collection.uuid,
            searchText: searchText,
            scopes: isNoteActive ? [.native, .translation, .note] : [.native, .translation]
        )
        
        searchFetchController?.fetchRequest.predicate = request.predicate
        searchFetchController?.fetchRequest.sortDescriptors = request.sortDescriptors
        try? searchFetchController?.performFetch()
        
        viewModel.noteCards = searchFetchController?.fetchedObjects ?? []
        viewModel.updateSnapshot(animated: true)
    }
    
    func handleSearchCancel() {
        viewModel.noteCards = appState.currenNoteCards
        viewModel.updateSnapshot(animated: true)
        searchFetchController = nil
    }
    
    func handleSearchNoteActiveChanged(_ isActive: Bool) {
        handleSearchTextDebounced(currentSearchText)
    }
    
    func handleOnReceiveCurrentNotesCardWillChange(_ value: Void) {
        guard searchFetchController != nil else { return }
        handleSearchTextDebounced(currentSearchText)
    }
}


// MARK: - Nav Bar Item

extension HomeNoteCardView {
    
    var trailingNavItems: some View {
        HStack(spacing: 8) {
            if iPad {
                sortOptionPopoverNavItem
            } else {
                sortOptionNavItem
            }
            createNoteCardNavItem
        }
    }
    
    var sortOptionNavItem: some View {
        NoteCardSortNavigationButton(
            sortOption: userPreference.noteCardSortOption,
            ascending: userPreference.noteCardSortOptionAscending,
            action: { self.showSortOption = true }
        )
            .disabled(searchFetchController != nil)
    }
    
    var sortOptionPopoverNavItem: some View {
        let popoverView = NoteCardSortOptionPopoverView(onSelected: { option, ascending in
            self.setNoteCardSortOption(option, ascending: ascending)
            self.showSortOption = false
        })
        
        return sortOptionNavItem.popover(
            isPresented: $showSortOption,
            attachmentAnchor: .point(.bottom),
            arrowEdge: .top,
            content: { popoverView }
        )
    }
    
    var createNoteCardNavItem: some View {
        NavigationBarButton(imageName: "plus", action: beginCreateNoteCard)
    }
}


// MARK: - Create Note Card

extension HomeNoteCardView {
    
    func beginCreateNoteCard() {
        let formModel = NoteCardFormModel(collection: collection)
        noteCardFormModel = formModel
        
        formModel.selectableCollections = appState.collections
        formModel.selectableRelationships = appState.currenNoteCards
        formModel.selectableTags = appState.tags
        formModel.relationshipSelectedCollection = collection
        
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
        
        formModel.onCreateTag = { name in
            self.handleNoteCardFormCreateTag(name: name, formModel: formModel)
        }
        
        formModel.onRelationshipCollectionSelected = { collection in
            self.handleRelationshipCollectionSelected(collection, formModel: formModel)
        }
        
        formModel.commitTitle = "Create"
        formModel.navigationTitle = "New Card"
        
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
        formModel.relationshipSelectedCollection = collection
        
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
        
        formModel.onCreateTag = { name in
            self.handleNoteCardFormCreateTag(name: name, formModel: formModel)
        }
        
        formModel.onRelationshipCollectionSelected = { collection in
            self.handleRelationshipCollectionSelected(collection, formModel: formModel)
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
        handleNoteCardCUDResult(result)
    }
}


// MARK: - Note Card Quick Button

extension HomeNoteCardView {
    
    func handleNoteCardQuickButtonTapped(_ button: NoteCardCell.QuickButtonType, noteCard: NoteCard) {
        switch button {
        case .relationship:
            if relationshipViewModel == nil {
                relationshipViewModel = .init()
            }
            
            let relationships = noteCard.relationships.sorted(by: { $0.translation < $1.translation })
            relationshipViewModel?.noteCards = [noteCard] + relationships
            relationshipViewModel?.cellStyle = .short
            relationshipViewModel?.contextMenus = [.copyNative]
            relationshipViewModel?.disableNoteCardIDs = [noteCard.uuid]
            
            relationshipViewModel?.onContextMenuSelected = { menu, noteCard in
                guard menu == .copyNative else { return }
                UIPasteboard.general.string = noteCard.native
            }
            
            relationshipViewModel?.onNoteCardSelected = { noteCard in
                self.handleNoteCardQuickButtonTapped(.relationship, noteCard: noteCard)
                self.relationshipViewModel?.reloadDisableCells()
                self.relationshipViewModel?.updateSnapshot(animated: true)
            }
            sheet = .noteCardRelationship
        
        case .tag:
            tagViewModel = .init()
            tagViewModel?.tags = noteCard.tags.sortedByName()
            sheet = .noteCardTag
        
        case .favorite:
            noteCard.isFavorite.toggle()
            noteCard.managedObjectContext?.quickSave()
        
        case .note:
            textViewModel = .init()
            textViewModel.renderMarkdown = userPreference.useMarkdown
            textViewModel.renderSoftBreak = userPreference.useMarkdownSoftBreak
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
        case .copyNative:
            UIPasteboard.general.string = noteCard.native
        }
    }
}


// MARK: - Form Model Handler

extension HomeNoteCardView {
    
    func handleNoteCardFormCollectionSelected(_ collection: NoteCardCollection, formModel: NoteCardFormModel) {
        formModel.selectedCollection = collection
        formModel.relationshipSelectedCollection = collection
        formModel.selectableRelationships = collection.noteCards.sorted(by: { $0.translation < $1.translation })
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
    
    func handleNoteCardFormCreateTag(name: String, formModel: NoteCardFormModel) -> Tag? {
        let request = TagCUDRequest(name: name)
        let result = appState.createTag(with: request)
        
        switch result {
        case .created(let tag, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchTags()
            let newTag = tag.get(from: appState.parentContext)
            formModel.selectableTags.insert(newTag, at: 0)
            formModel.selectedTags.insert(newTag)
            return newTag
        
        case .failed: // TODO: inform user if needed
            return nil
        
        case .updated, .deleted, .unchanged:
            fatalError("🧨 attempt to \(result) in handleNoteCardFormCreateTag method 🧨")
        }
    }
    
    func handleRelationshipCollectionSelected(_ collection: NoteCardCollection, formModel: NoteCardFormModel) {
        formModel.selectableRelationships = collection.noteCards.sorted(by: { $0.translation < $1.translation })
        formModel.relationshipSelectedCollection = collection
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
            
        case .deleted(let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchCurrentNoteCards()
            viewModel.noteCards = appState.currenNoteCards
            viewModel.updateSnapshot(animated: true)
            sheet = nil
            
        case .failed, .unchanged: // TODO: show alert if needed
            sheet = nil
        }
    }
}


struct HomeNoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        HomeNoteCardView(viewModel: .init(), collection: .sample, collectionView: .init(frame: .zero, collectionViewLayout: .init()))
    }
}
