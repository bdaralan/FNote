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
import BDSwiftility


struct HomeNoteCardView: View {
        
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var userPreference: UserPreference
    
    var viewModel: NoteCardCollectionViewModel
    
    @State private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    @State private var sheet = BDPresentationItem<Sheet>()
    @State private var showSortOption = false

    @State private var trayViewModel = BDButtonTrayViewModel()
    
    @State private var noteCardFormModel: NoteCardFormModel?
    @State private var relationshipViewModel: NoteCardCollectionViewModel?
    @State private var tagViewModel: TagCollectionViewModel?
    @State private var textViewModel = ModalTextViewModel()
    @State private var textFieldModel = BDModalTextFieldModel()
    
    @State private var alert: Alert?
    @State private var presentAlert = false
    
    @State private var searchFetchController: NSFetchedResultsController<NoteCard>?
    @State private var currentSearchText = ""
    
    var currentCollection: NoteCardCollection? {
        appState.currentCollection
    }
    
    var navigationTitle: String {
        if currentCollection?.managedObjectContext == nil {
            return "FNote"
        }
        return currentCollection?.name ?? ""
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                CollectionViewWrapper(viewModel: viewModel, collectionView: collectionView)
                    .navigationBarTitle(Text(navigationTitle), displayMode: .large)
                    .edgesIgnoringSafeArea(.all)
                
                if appState.currentCollection?.managedObjectContext == nil || !appState.iCloudActive {
                    WelcomeGuideView(iCloudActive: appState.iCloudActive, action: beginCreateNoteCardCollection)
                }
                
                Color.clear.overlay(buttonTrayView, alignment: .bottomTrailing)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet.current, onDismiss: presentationSheetDismissed, content: presentationSheet)
        .alert(isPresented: $presentAlert, content: { self.alert! })
        .onReceive(appState.currentNoteCardsWillChange, perform: handleOnReceiveCurrentNotesCardWillChange)
        .onAppear(perform: setupOnAppear)
    }
}


// MARK: - Sheet & Alert

extension HomeNoteCardView {
    
    enum Sheet: BDPresentationSheetItem {
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
            
        case .noteCardTag:
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
            
        case .noteCardNote:
            return ModalTextView(viewModel: $textViewModel)
                .eraseToAnyView()
            
        case .noteCardCollection:
            let selected = handleNoteCardCollectionSelected
            let deleted = handleNoteCardCollectionDeleted
            let done = { self.sheet.dismiss() }
            return HomeNoteCardCollectionView(
                onSelected: selected,
                onRenamed: nil,
                onDeleted: deleted,
                onDone: done
            )
                .environmentObject(appState)
                .eraseToAnyView()
            
        case .modalTextField:
            return BDModalTextField(viewModel: $textFieldModel)
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
            .padding(16)
            .disabled(searchFetchController != nil)
    }
    
    func setupButtonTrayViewModel() {
        trayViewModel.setDefaultColors()
        trayViewModel.mainItem = createTrayMainItem()
        trayViewModel.items = createTrayItems()
        
        trayViewModel.onTrayWillExpand = { willExpand in
            // when collapsed, remove subitems
            // delay a bit so it doesn't show the main item label sliding down
            guard !willExpand else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                self.trayViewModel.subitems = []
            }
        }
    }
    
    func createTrayMainItem() -> BDButtonTrayItem {
        BDButtonTrayItem(title: "", systemImage: "plus") { item in
            if self.currentCollection == nil {
                self.presentCannotCreateNoteCardAlert()
            } else {
                self.beginCreateNoteCard()
            }
        }
    }
    
    func createTrayItems() -> [BDButtonTrayItem] {
        // show all collections
        let collections = BDButtonTrayItem(title: "Collections", systemImage: "rectangle.stack") { item in
            self.sheet.present(.noteCardCollection)
        }
        
        // create new collection
        let createCollection = BDButtonTrayItem(title: "New Collection", systemImage: "rectangle.stack.badge.plus") { item in
            self.beginCreateNoteCardCollection()
        }
        
        let sortCards = BDButtonTrayItem(title: "Sort", systemImage: "arrow.up.arrow.down.circle") { item in
            self.trayViewModel.subitems = self.createNoteCardSortOptionTrayItems()
        }
        
        return [createCollection, collections, sortCards]
    }
    
    func createNoteCardSortOptionTrayItems() -> [BDButtonTrayItem] {
        var nativeItem: BDButtonTrayItem!
        var translationItem: BDButtonTrayItem!
        
        // give the next correct ascending boolean value for the item once triggered
        // example if currently N ascending, then select a different option should still return ascending
        let computeAscending = { (option: NoteCardSortField) -> Bool in
            let currentOption = self.appState.noteCardSortOption
            let currentAscending = self.appState.noteCardSortOptionAscending
            let ascending = currentOption == option ? !currentAscending : currentAscending
            return ascending
        }
        
        // give the correct title for the item match with app state's sort option
        // current active item has arrow attached to it
        // example if currently or select N and it shows N↓, then select T should should show T↓ (not T↑)
        let computeItemTitle = { (option: NoteCardSortField) -> String in
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
        textFieldModel.prompt = "Name cannot contain comma ,"
        
        textFieldModel.onCancel = {
            self.sheet.dismiss()
        }
        
        textFieldModel.onReturnKey = {
            self.commitCreateNoteCardCollection()
        }
        
        textFieldModel.isFirstResponder = true
        sheet.present(.modalTextField)
    }
    
    func commitCreateNoteCardCollection() {
        let name = textFieldModel.text.trimmed()
        
        guard !name.isEmpty else {
            textFieldModel.isFirstResponder = false
            sheet.dismiss()
            return
        }
        
        if appState.isDuplicateCollectionName(name) {
            textFieldModel.prompt = "Duplicate collection name!"
            textFieldModel.promptColor = .red
            return
        }
        
        let parentContext = appState.parentContext
        var collectionModifier = ObjectModifier<NoteCardCollection>(.create(parentContext))
        collectionModifier.name = name
        collectionModifier.save()
        
        let newCollection = collectionModifier.modifiedObject.get(from: parentContext)
        appState.fetchCollections()
        appState.setCurrentCollection(newCollection)
        textFieldModel.isFirstResponder = false
        trayViewModel.expanded = false
        sheet.dismiss()
    }
    
    func setNoteCardSortOption(_ option: NoteCardSortField, ascending: Bool) {
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
        sheet.dismiss()
    }
    
    func handleNoteCardCollectionDeleted(collectionID: String) {
        guard currentCollection == nil else { return }
        viewModel.noteCards = appState.currentNoteCards
        viewModel.updateSnapshot(animated: false)
    }
    
    func presentCannotCreateNoteCardAlert() {
        let title = Text("Cannot Create Note Card")
        let message = Text("Make sure a collection is selected")
        let dismiss = Alert.Button.default(Text("Dismiss"), action: { self.alert  = nil })
        alert = Alert(title: title, message: message, dismissButton: dismiss)
        presentAlert = true
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
            collectionUUID: collection.uuid,
            searchText: searchText,
            searchFields: isNoteActive ? [.native, .translation, .note] : [.native, .translation]
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
        formModel.presentWithKeyboard = true
        
        sheet.present(.noteCardForm)
    }
    
    func commitCreateNoteCard() {
        guard let formModel = noteCardFormModel else { return }
        guard let collection = formModel.selectedCollection else { return }
        
        var cardModifier = ObjectModifier<NoteCard>(.create(appState.parentContext))
        cardModifier.setCollection(collection)
        cardModifier.native = formModel.native
        cardModifier.translation = formModel.translation
        cardModifier.formality = formModel.selectedFormality
        cardModifier.isFavorite = formModel.isFavorite
        cardModifier.note = formModel.note
        cardModifier.setRelationships(formModel.selectedRelationships)
        cardModifier.setTags(formModel.selectedTags)
        cardModifier.save()
        
        appState.fetchCurrentNoteCards()
        viewModel.noteCards = appState.currentNoteCards
        viewModel.updateSnapshot(animated: true)
        sheet.dismiss()
    }
    
    func cancelCreateNoteCard() {
        sheet.dismiss()
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
        
        sheet.present(.noteCardForm)
    }
    
    func cancelEditNoteCard() {
        sheet.dismiss()
    }
    
    func commitEditNoteCard(_ noteCard: NoteCard) {
        guard let formModel = noteCardFormModel else { return }
        guard let collection = formModel.selectedCollection else { return }
        
        var cardModifier = ObjectModifier<NoteCard>(.update(noteCard))
        cardModifier.setCollection(collection)
        cardModifier.native = formModel.native
        cardModifier.translation = formModel.translation
        cardModifier.formality = formModel.selectedFormality
        cardModifier.isFavorite = formModel.isFavorite
        cardModifier.note = formModel.note
        cardModifier.setRelationships(formModel.selectedRelationships)
        cardModifier.setTags(formModel.selectedTags)
        cardModifier.save()
        
        if collection.uuid != currentCollection?.uuid {
            appState.fetchCurrentNoteCards()
            viewModel.noteCards = appState.currentNoteCards
            viewModel.updateSnapshot(animated: true)
        }
        
        sheet.dismiss()
    }
}


// MARK: - Delete Note Card

extension HomeNoteCardView {
    
    func beginDeleteNoteCard(_ noteCard: NoteCard) {
        let delete = { self.commitDeleteNoteCard(noteCard) }
        let cancel = { self.alert = nil }
        alert = Alert.DeleteNoteCard(noteCard, onCancel: cancel, onDelete: delete)
        presentAlert = true
    }
    
    func commitDeleteNoteCard(_ noteCard: NoteCard) {
        let cardModifier = ObjectModifier<NoteCard>(.update(noteCard))
        cardModifier.delete()
        cardModifier.save()
        
        appState.fetchCurrentNoteCards()
        viewModel.noteCards = appState.currentNoteCards
        viewModel.updateSnapshot(animated: true)
        alert = nil
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
            sheet.present(.noteCardRelationship)
        
        case .tag:
            tagViewModel = .init()
            tagViewModel?.tags = noteCard.tags.sortedByName()
            sheet.present(.noteCardTag)
        
        case .favorite:
            var cardModifier = ObjectModifier<NoteCard>(.update(noteCard))
            cardModifier.isFavorite = !noteCard.isFavorite
            cardModifier.save()
        
        case .note:
            textViewModel = .init()
            textViewModel.renderMarkdown = userPreference.useMarkdown
            textViewModel.renderSoftBreak = userPreference.useMarkdownSoftBreak
            textViewModel.disableEditing = true
            textViewModel.title = "Note"
            textViewModel.text = noteCard.note
            textViewModel.onCommit = {
                self.sheet.dismiss()
            }
            sheet.present(.noteCardNote)
        }
    }
}


// MARK: - Note Card Context Menu

extension HomeNoteCardView {
    
    func handleContextMenuSelected(_ menu: NoteCardCell.ContextMenu, noteCard: NoteCard) {
        switch menu {
        case .delete:
            beginDeleteNoteCard(noteCard)
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
        if appState.isDuplicateTagName(name) {
            return nil
        }
        
        let parentContext = appState.parentContext
        var tagModifier = ObjectModifier<Tag>(.create(parentContext))
        tagModifier.name = name
        tagModifier.save()
        
        appState.fetchTags()
        
        let newTag = tagModifier.modifiedObject.get(from: parentContext)
        formModel.selectableTags.insert(newTag, at: 0)
        formModel.selectedTags.insert(newTag)
        
        return newTag
    }
    
    func handleRelationshipCollectionSelected(_ collection: NoteCardCollection, formModel: NoteCardFormModel) {
        formModel.selectableRelationships = collection.noteCards.sorted(by: { $0.translation < $1.translation })
        formModel.relationshipSelectedCollection = collection
    }
}


struct HomeNoteCardView_Previews: PreviewProvider {
    static let appState = AppState(parentContext: .sample)
    static let preference = UserPreference.shared
    static let viewModel = NoteCardCollectionViewModel()
    static var previews: some View {
        HomeNoteCardView(viewModel: viewModel)
            .environmentObject(preference)
            .environmentObject(appState)
    }
}
