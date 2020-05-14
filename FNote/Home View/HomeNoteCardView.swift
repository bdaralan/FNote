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
        
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var userPreference: UserPreference
    
    var viewModel: NoteCardCollectionViewModel
    
    @State private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    @State private var sheet = BDPresentationItem<Sheet>()
    @State private var showSortOption = false

    @State private var trayViewModel = BDButtonTrayViewModel()
    @State private var textFieldModel = BDModalTextFieldModel()
    @State private var cardPresenterModel: NoteCardDetailPresenterModel!
    
    @State private var alert: Alert?
    @State private var presentAlert = false
    
    @State private var nativeSortTrayItem: BDButtonTrayItem!
    @State private var translationSortTrayItem: BDButtonTrayItem!
    
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
                
                cardPresenterModel.map { viewModel in
                    NoteCardDetailPresenter(viewModel: viewModel)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet.current, content: presentationSheet)
        .alert(isPresented: $presentAlert, content: { self.alert! })
        .onAppear(perform: setupOnAppear)
    }
}


// MARK: - Setup

extension HomeNoteCardView {
    
    func setupOnAppear() {
        setupCardPresenterModel()
        setupViewModel()
        setupButtonTrayViewModel()
    }
    
    func setupCardPresenterModel() {
        cardPresenterModel = .init(appState: appState)
        cardPresenterModel.renderMarkdown = userPreference.useMarkdown
        cardPresenterModel.renderSoftBreak = userPreference.useMarkdownSoftBreak
    }
    
    func setupViewModel() {
        viewModel.sectionContentInsets.bottom = 140
        
        viewModel.noteCards = appState.currentNoteCards
        viewModel.contextMenus = [.copyNative, .delete]
        
        viewModel.onNoteCardSelected = { noteCard in
            self.cardPresenterModel.sheet = .edit(noteCard: noteCard) {
                guard noteCard.collection?.uuid != self.currentCollection?.uuid else { return }
                self.appState.fetchCurrentNoteCards()
                self.viewModel.noteCards = self.appState.currentNoteCards
                self.viewModel.updateSnapshot(animated: true)
            }
        }
        
        viewModel.onNoteCardQuickButtonTapped = handleNoteCardQuickButtonTapped
        viewModel.onContextMenuSelected = handleContextMenuSelected
        viewModel.setupCollectionView(collectionView)
    }
}


// MARK: - Sheet & Alert

extension HomeNoteCardView {
    
    enum Sheet: BDPresentationSheetItem {
        case searchNoteCard
        case noteCardCollection
        case modalTextField
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
            
        case .searchNoteCard:
            return NoteCardSearchView(
                appState: appState,
                onCancel: { self.sheet.dismiss() }
            )
                .eraseToAnyView()
            
        case .noteCardCollection:
            return HomeNoteCardCollectionView(
                onSelected: handleNoteCardCollectionSelected,
                onRenamed: nil,
                onDeleted: handleNoteCardCollectionDeleted,
                onDone: { self.sheet.dismiss() }
            )
                .environmentObject(appState)
                .eraseToAnyView()
            
        case .modalTextField:
            return BDModalTextField(viewModel: $textFieldModel)
                .eraseToAnyView()
        }
    }
}


// MARK: - Button Tray View

extension HomeNoteCardView {
    
    var buttonTrayView: some View {
        BDButtonTrayView(viewModel: trayViewModel)
            .padding(16)
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
        BDButtonTrayItem(title: "", image: .system(SFSymbol.add)) { item in
            guard let collection = self.currentCollection else {
                self.presentCannotCreateNoteCardAlert()
                return
            }
            
            self.cardPresenterModel.sheet = .create(noteCardIn: collection) {
                self.appState.fetchCurrentNoteCards()
                self.viewModel.noteCards = self.appState.currentNoteCards
                self.viewModel.updateSnapshot(animated: true)
            }
        }
    }
    
    func createTrayItems() -> [BDButtonTrayItem] {
        // show all collections
        let collections = BDButtonTrayItem(title: "Collections", image: .system(SFSymbol.collection)) { item in
            self.sheet.present(.noteCardCollection)
        }
        
        // create new collection
        let createCollection = BDButtonTrayItem(title: "New Collection", image: .system(SFSymbol.addCollection)) { item in
            self.beginCreateNoteCardCollection()
        }
        
        let sortCards = BDButtonTrayItem(title: "Sort", image: .system(SFSymbol.sort)) { item in
            self.trayViewModel.subitems = self.createNoteCardSortOptionTrayItems()
        }
        
        let searchCards = BDButtonTrayItem(title: "Search", image: .system(SFSymbol.search)) { item in
            self.sheet.present(.searchNoteCard)
        }
        
        return [createCollection, collections, sortCards, searchCards]
    }
    
    func createNoteCardSortOptionTrayItems() -> [BDButtonTrayItem] {
        let getAscendingFor = { (option: NoteCard.SearchField) -> Bool in
            let currentOption = self.appState.noteCardSortOption
            let currentAscending = self.appState.noteCardSortOptionAscending
            return currentOption == option ? !currentAscending : currentAscending
        }
        
        let nativeItem = BDButtonTrayItem(title: "", image: .system(SFSymbol.option)) { item in
            self.setNoteCardSortOption(.native, ascending: getAscendingFor(.native))
        }
        
        let translationItem = BDButtonTrayItem(title: "", image: .system(SFSymbol.option)) { item in
            self.setNoteCardSortOption(.translation, ascending: getAscendingFor(.translation))
        }
        
        nativeSortTrayItem = nativeItem
        translationSortTrayItem = translationItem
        setNoteCardSortOption(appState.noteCardSortOption, ascending: appState.noteCardSortOptionAscending)
        
        return [nativeItem, translationItem]
    }
    
    func setNoteCardSortOption(_ option: NoteCard.SearchField, ascending: Bool) {
        nativeSortTrayItem.title = "By Native"
        translationSortTrayItem.title = "By Translation"
        
        let arrow = ascending ? "↓" : "↑"
        switch option {
        case .native:
            nativeSortTrayItem.title.append(" \(arrow)")
            nativeSortTrayItem.activeColor = .accentColor
            nativeSortTrayItem.image = .system(SFSymbol.selectedOption)
            translationSortTrayItem.image = .system(SFSymbol.option)
            translationSortTrayItem.activeColor = .buttonTrayItemUnfocused
            
        case .translation:
            translationSortTrayItem.title.append(" \(arrow)")
            translationSortTrayItem.activeColor = .accentColor
            translationSortTrayItem.image = .system(SFSymbol.selectedOption)
            nativeSortTrayItem.image = .system(SFSymbol.option)
            nativeSortTrayItem.activeColor = .buttonTrayItemUnfocused
        }
        
        // reload if changed
        guard appState.noteCardSortOption != option || appState.noteCardSortOptionAscending != ascending else { return }
        userPreference.noteCardSortOption = option
        userPreference.noteCardSortOptionAscending = ascending
        
        appState.noteCardSortOption = option
        appState.noteCardSortOptionAscending = ascending
        appState.fetchCurrentNoteCards()
        
        viewModel.noteCards = appState.currentNoteCards
        viewModel.updateSnapshot(animated: true)
    }
    
    func updateTraySortItemsState(sortField: NoteCard.SearchField, ascending: Bool, native: BDButtonTrayItem, translation: BDButtonTrayItem) {
        
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
        var collectionModifier = ObjectModifier<NoteCardCollection>(.create(in: parentContext))
        collectionModifier.name = name
        collectionModifier.save()
        
        let newCollection = collectionModifier.modifiedObject.get(from: parentContext)
        appState.fetchCollections()
        appState.setCurrentCollection(newCollection)
        textFieldModel.isFirstResponder = false
        trayViewModel.expanded = false
        sheet.dismiss()
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


// MARK: - Note Card Quick Button

extension HomeNoteCardView {
    
    func handleNoteCardQuickButtonTapped(_ button: NoteCardCell.QuickButtonType, noteCard: NoteCard) {
        switch button {
        case .relationship:
            cardPresenterModel.sheet = .relationship(noteCard)
        case .tag:
            cardPresenterModel.sheet = .tag(noteCard)
        case .note:
            cardPresenterModel.sheet = .note(noteCard)
        case .favorite:
            cardPresenterModel.setFavorite(!noteCard.isFavorite, for: noteCard)
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
