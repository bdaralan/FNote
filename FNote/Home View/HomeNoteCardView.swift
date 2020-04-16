//
//  HomeNoteCardView.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData
import BDUIKnit


struct HomeNoteCardView: View {
        
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userPreference: UserPreference
    
    var viewModel: NoteCardCollectionViewModel
    
    @State private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    @State private var sheet: Sheet?
    @State private var showSortOption = false

    @State private var trayViewModel = BDButtonTrayViewModel()
    
    @State private var noteCardFormModel: NoteCardFormModel?
    @State private var relationshipViewModel: NoteCardCollectionViewModel?
    @State private var tagViewModel: TagCollectionViewModel?
    @State private var textViewModel = ModalTextViewModel()
    @State private var textFieldModel = ModalTextFieldModel()
    
    @State private var noteCardToDelete: NoteCard?
    
    @State private var searchFetchController: NSFetchedResultsController<NoteCard>?
    @State private var currentSearchText = ""
    
    var currentCollection: NoteCardCollection? {
        appState.currentCollection
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                CollectionViewWrapper(viewModel: viewModel, collectionView: collectionView)
                    .navigationBarTitle(Text(currentCollection?.name ?? "FNote"), displayMode: .large)
                    .edgesIgnoringSafeArea(.all)
                
                if appState.currentCollection?.managedObjectContext == nil || !appState.iCloudActive {
                    WelcomeGuideView(iCloudActive: appState.iCloudActive, action: beginCreateNoteCardCollection)
                }
                
                Color.clear.overlay(buttonTrayView, alignment: .bottomTrailing)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet, onDismiss: presentationSheetDismissed, content: presentationSheet)
        .alert(item: $noteCardToDelete, content: deleteNoteCardAlert)
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
        case noteCardCollection
        case modalTextField
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
            
        case .noteCardCollection:
            let selected = handleNoteCardCollectionSelected
            let deleted = handleNoteCardCollectionDeleted
            let done = { self.sheet = nil }
            return HomeNoteCardCollectionView(
                onSelected: selected,
                onRenamed: nil,
                onDeleted: deleted,
                onDone: done
            )
                .environmentObject(appState)
                .eraseToAnyView()
            
        case .modalTextField:
            return ModalTextField(viewModel: $textFieldModel)
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
        setupViewModel()
        setupButtonTrayViewModel()
    }
    
    func setupViewModel() {
        viewModel.sectionContentInsets.bottom = 140
        viewModel.contextMenus = [.copyNative, .delete]
        viewModel.noteCards = appState.currentNoteCards
        viewModel.onNoteCardSelected = beginEditNoteCard
        viewModel.onNoteCardQuickButtonTapped = handleNoteCardQuickButtonTapped
        viewModel.onContextMenuSelected = handleContextMenuSelected
        viewModel.onSearchTextDebounced = handleSearchTextDebounced
        viewModel.onSearchCancel = handleSearchCancel
        viewModel.onSearchNoteActiveChanged = handleSearchNoteActiveChanged
        
        viewModel.setupCollectionView(collectionView)
    }
}


// MARK: - Button Tray View

extension HomeNoteCardView {
    
    var buttonTrayView: some View {
        BDButtonTrayView(viewModel: trayViewModel)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 16))
            .disabled(searchFetchController != nil)
    }
    
    func setupButtonTrayViewModel() {
        // show all collections
        let collectionItem = BDButtonTrayItem(title: "Collections", systemImage: "rectangle.stack") { item in
            self.sheet = .noteCardCollection
        }
        
        // create new collection
        let addCollectionItem = BDButtonTrayItem(title: "New Collection", systemImage: "rectangle.stack.badge.plus") { item in
            self.beginCreateNoteCardCollection()
        }
        
        let sortCardsItem = BDButtonTrayItem(title: "Sort", systemImage: "arrow.up.arrow.down.circle") { item in
            self.trayViewModel.subitems = self.createNoteCardSortOptionTrayItems()
        }
        
        trayViewModel.buttonSystemImage = "plus"
        trayViewModel.items = [addCollectionItem, collectionItem, sortCardsItem]
        
        trayViewModel.action = {
            self.beginCreateNoteCard()
        }
        
        trayViewModel.onTrayWillExpand = { willExpand in
            // when collapsed, remove subitems
            // delay a bit so it doesn't show the main item label sliding down
            guard !willExpand else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                self.trayViewModel.subitems = []
            }
        }
    }
    
    func createNoteCardSortOptionTrayItems() -> [BDButtonTrayItem] {
        var nativeItem: BDButtonTrayItem!
        var translationItem: BDButtonTrayItem!
        
        // give the next correct ascending boolean value for the item once triggered
        // example if currently N ascending, then select a different option should still return ascending
        let computeAscending = { (option: NoteCardSortOption) -> Bool in
            let currentOption = self.appState.noteCardSortOption
            let currentAscending = self.appState.noteCardSortOptionAscending
            let ascending = currentOption == option ? !currentAscending : currentAscending
            return ascending
        }
        
        // give the correct title for the item match with app state's sort option
        // current active item has arrow attached to it
        // example if currently or select N and it shows N↓, then select T should should show T↓ (not T↑)
        let computeItemTitle = { (option: NoteCardSortOption) -> String in
            let currentOption = self.appState.noteCardSortOption
            let arrow = self.appState.noteCardSortOptionAscending ? "↓" : "↑"
            let attachingArrow = currentOption == option ? " \(arrow)" : ""
            let title = "\(option.trayItemTitle)\(attachingArrow)"
            return title
        }
        
        nativeItem = BDButtonTrayItem(title: computeItemTitle(.native), systemImage: "n.circle") { item in
            self.setNoteCardSortOption(.native, ascending: computeAscending(.native))
            item.title = computeItemTitle(.native)
            translationItem.title = computeItemTitle(.translation)
        }
        
        translationItem = BDButtonTrayItem(title: computeItemTitle(.translation), systemImage: "t.circle") { item in
            self.setNoteCardSortOption(.translation, ascending: computeAscending(.translation))
            item.title = computeItemTitle(.translation)
            nativeItem.title = computeItemTitle(.native)
        }
        
        return [nativeItem, translationItem]
    }
    
    func beginCreateNoteCardCollection() {
        textFieldModel = .init()
        textFieldModel.title = "New Collection"
        textFieldModel.placeholder = "name"
        textFieldModel.isFirstResponder = true
        
        textFieldModel.onCancel = {
            self.sheet = nil
        }
        
        textFieldModel.onReturnKey = {
            self.commitCreateNoteCardCollection()
        }
        
        sheet = .modalTextField
    }
    
    func commitCreateNoteCardCollection() {
        let name = textFieldModel.text.trimmed()
        
        guard !name.isEmpty else {
            sheet = nil
            return
        }
        
        let request = NoteCardCollectionCUDRequest(name: name)
        let result = appState.createNoteCardCollection(with: request)
        
        switch result {
        case .deleted, .updated, .unchanged:
            fatalError("🧨 unexpected use case for commitCreateNoteCardCollection 🧨")
        
        case .created(let collection, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            let collection = collection.get(from: appState.parentContext)
            appState.fetchCollections()
            appState.setCurrentCollection(collection)
            textFieldModel.isFirstResponder = false
            trayViewModel.expanded = false
            sheet = nil
        
        case .failed:
            textFieldModel.prompt = "Duplicate collection name!"
            textFieldModel.promptColor = .orange
        }
    }
    
    func setNoteCardSortOption(_ option: NoteCardSortOption, ascending: Bool) {
        let currentOption = appState.noteCardSortOption
        let currentAscending = appState.noteCardSortOptionAscending
        
        guard currentOption != option || currentAscending != ascending else { return }
        userPreference.noteCardSortOption = option
        userPreference.noteCardSortOptionAscending = ascending
        
        appState.noteCardSortOption = option
        appState.noteCardSortOptionAscending = ascending
        appState.fetchCurrentNoteCards()
        
        viewModel.noteCards = appState.currentNoteCards
        viewModel.updateSnapshot(animated: true)
    }
    
    func handleNoteCardCollectionSelected(_ collection: NoteCardCollection) {
        viewModel.scrollToTop(animated: false)
        
        viewModel.noteCards = appState.currentNoteCards
        viewModel.updateSnapshot(animated: false)
        
        trayViewModel.expanded = false
        sheet = nil
    }
    
    func handleNoteCardCollectionDeleted(collectionID: String) {
        guard currentCollection == nil else { return }
        viewModel.noteCards = appState.currentNoteCards
        viewModel.updateSnapshot(animated: false)
    }
}


// MARK: - Search

extension HomeNoteCardView {
    
    func handleSearchTextDebounced(_ searchText: String) {
        currentSearchText = searchText
        
        if trayViewModel.expanded {
            trayViewModel.expanded = false
            trayViewModel.subitems = []
        }
        
        guard !searchText.trimmed().isEmpty, let collection = currentCollection else {
            viewModel.noteCards = appState.currentNoteCards
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
        viewModel.noteCards = appState.currentNoteCards
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


// MARK: - Create Note Card

extension HomeNoteCardView {
    
    func beginCreateNoteCard() {
        let formModel = NoteCardFormModel(collection: currentCollection)
        noteCardFormModel = formModel
        
        formModel.selectableCollections = appState.collections
        formModel.selectableRelationships = appState.currentNoteCards
        formModel.selectableTags = appState.tags
        formModel.relationshipSelectedCollection = currentCollection
        
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
        formModel.selectableRelationships = appState.currentNoteCards
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
        Alert.DeleteNoteCard(noteCard, onCancel: nil, onDelete: {
            self.commitDeleteNoteCard(noteCard)
        })
    }
    
    func commitDeleteNoteCard(_ noteCard: NoteCard) {
        let result = appState.deleteObject(noteCard)
        handleNoteCardCUDResult(result)
    }
}


// MARK: - Note Card Quick Button

extension HomeNoteCardView {
    
    func handleNoteCardQuickButtonTapped(_ button: NoteCardCell.QuickButtonType, noteCard: NoteCard) {
        switch button {
        case .relationship:
            let model = NoteCardCollectionViewModel()
            model.cellStyle = .short
            model.contextMenus = [.copyNative]
            
            let setupDisplayRelationships: (NoteCard) -> Void = { noteCard in
                let relationships = noteCard.relationships.sorted(by: { $0.translation < $1.translation })
                model.noteCards = [noteCard] + relationships
                model.borderedNoteCardIDs = [noteCard.uuid]
                model.ignoreSelectionNoteCardIDs = [noteCard.uuid]
            }
            
            model.onContextMenuSelected = { menu, noteCard in
                guard menu == .copyNative else { return }
                UIPasteboard.general.string = noteCard.native
            }
            
            model.onNoteCardSelected = { noteCard in
                // setup cards to display
                // clear current bordered cells
                // show the cards to display
                setupDisplayRelationships(noteCard)
                model.reloadedVisibleCells()
                model.updateSnapshot(animated: true)
            }
            
            setupDisplayRelationships(noteCard)
            relationshipViewModel = model
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
            viewModel.noteCards = appState.currentNoteCards
            viewModel.updateSnapshot(animated: true)
            sheet = nil
            
        case .updated(let noteCard, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            if noteCard.collection?.uuid != currentCollection?.uuid {
                appState.fetchCurrentNoteCards()
                viewModel.noteCards = appState.currentNoteCards
                viewModel.updateSnapshot(animated: true)
            }
            sheet = nil
            
        case .deleted(let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchCurrentNoteCards()
            viewModel.noteCards = appState.currentNoteCards
            viewModel.updateSnapshot(animated: true)
            
        case .failed, .unchanged: // TODO: show alert if needed
            sheet = nil
        }
    }
}


struct HomeNoteCardView_Previews: PreviewProvider {
    static let appState = AppState(parentContext: .sample)
    static let preference = UserPreference.shared
    static let viewModel = NoteCardCollectionViewModel()
    static let collection = NoteCardCollection.sample
    static let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    static var previews: some View {
        HomeNoteCardView(viewModel: viewModel)
            .environmentObject(preference)
            .environmentObject(appState)
    }
}
