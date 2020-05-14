//
//  NoteCardSearchView.swift
//  FNote
//
//  Created by Dara Beng on 5/9/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit
import CoreData


struct NoteCardSearchView: View {
    
    var appState: AppState
    
    @State private var searchField = SearchField()
    @State private var searchFieldPlaceholder = ""
    @State private var isSearchFieldFirstResponder = true
    @State private var currentSearchCollection: NoteCardCollection?
    @State private var fetchController: NSFetchedResultsController<NoteCard>?
    
    @State private var trayViewModel = BDButtonTrayViewModel()
    
    @State private var cardViewModel = NoteCardCollectionViewModel()
    @State private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    @State private var presenterModel: NoteCardDetailPresenterModel!
    
    var onCancel: (() -> Void)?
    
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .imageScale(.large)
                    .foregroundColor(Color(.placeholderText))
                
                BDTextFieldWrapper(
                    isActive: $isSearchFieldFirstResponder,
                    text: $searchField.searchText,
                    placeholder: searchFieldPlaceholder,
                    returnKeyType: .search,
                    onCommit: handleSearchReturnKey,
                    configure: configureSearchTextField
                )
                    .frame(height: 60)
                
                onCancel.map { cancel in
                    Button("Cancel", action: cancel)
                }
            }
            .padding(.horizontal, 16)
            
            Divider()
            
            ZStack {
                CollectionViewWrapper(viewModel: cardViewModel, collectionView: collectionView)
                    .edgesIgnoringSafeArea(.all)
                presenterModel.map { model in
                    NoteCardDetailPresenter(viewModel: model)
                }
            }
        }
        .onAppear(perform: setupOnAppear)
        .overlay(BDButtonTrayView(viewModel: trayViewModel).padding(16), alignment: .bottomTrailing)
    }
}


// MARK: - Setup

extension NoteCardSearchView {
    
    func setupOnAppear() {
        presenterModel = .init(appState: appState)
        setupSearchField()
        setupCardViewModel()
        setupTrayViewModel()
    }
    
    func configureSearchTextField(_ textField: UITextField) {
        textField.font = .preferredFont(forTextStyle: .body)
        textField.autocapitalizationType = .none // TODO: remove this on release
        textField.clearButtonMode = .always
    }
    
    func setupCardViewModel() {
        cardViewModel.sectionContentInsets.bottom = 140
        cardViewModel.setupCollectionView(collectionView)
    }
    
    func setupSearchField() {
        searchField.onSearchTextDebounced = { searchText in
            self.beginSearch(searchText: searchText)
        }
    }
    
    func handleSearchReturnKey() {
        isSearchFieldFirstResponder = false
    }
    
    func setupTrayViewModel() {
        trayViewModel.shouldDisableMainItemWhenExpanded = false
        trayViewModel.setDefaultColors()
        trayViewModel.items = createTrayItems()
        trayViewModel.mainItem = .init(title: "", image: .system(SFSymbol.search)) { item in
            self.isSearchFieldFirstResponder = true
        }
    }
    
    func createTrayItems() -> [BDButtonTrayItem] {
        var searchIn: BDButtonTrayItem!
        var searchAll: BDButtonTrayItem!
        
        let redoSearchAndCollapseTray = {
            // set a tiny delay to let user sees the item's state changed before the tray is collapsed
            self.updateSearchState(searchIn: searchIn, searchAll: searchAll)
            self.beginSearch(searchText: self.searchField.searchText)
            self.cardViewModel.scrollToTop(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                self.trayViewModel.expanded = false
            }
        }
        
        searchIn = BDButtonTrayItem(title: "", image: .system("")) { item in
            let selectedID = self.currentSearchCollection?.uuid
            self.presenterModel.sheet = .allCollections(title: "Search In", selectedID: selectedID) { collection in
                self.currentSearchCollection = collection
                self.presenterModel.sheet = nil
                redoSearchAndCollapseTray()
            }
        }
        
        searchAll = BDButtonTrayItem(title: "Search in all collections", image: .system("")) { item in
            self.currentSearchCollection = nil
            redoSearchAndCollapseTray()
        }
        
        updateSearchState(searchIn: searchIn, searchAll: searchAll)
        
        return [searchIn, searchAll]
    }
    
    func updateSearchState(searchIn: BDButtonTrayItem, searchAll: BDButtonTrayItem) {
        let selectedImage = SFSymbol.selectedOption
        let unselectedImage = SFSymbol.option
        let selectedColor = Color.appAccent
        let unselectedColor = Color.buttonTrayItemUnfocused
        
        if let collection = currentSearchCollection { // search selected collection
            searchIn.title = "Search in \(collection.name)"
            searchIn.image = .system(selectedImage)
            searchIn.activeColor = selectedColor
            searchAll.image = .system(unselectedImage)
            searchAll.activeColor = unselectedColor
            searchFieldPlaceholder = searchIn.title
        } else { // search all
            searchAll.image = .system(selectedImage)
            searchAll.activeColor = selectedColor
            searchIn.title = "Search in"
            searchIn.image = .system(unselectedImage)
            searchIn.activeColor = unselectedColor
            searchFieldPlaceholder = searchAll.title
        }
    }
    
    func beginSearch(searchText: String) {
        if searchText.trimmed().isEmpty {
            fetchController = nil
            let noteCards = currentSearchCollection == nil ? [] : appState.currentNoteCards
            cardViewModel.noteCards = noteCards
            cardViewModel.updateSnapshot(animated: true)
            return
        }
        
        let request = NoteCard.requestNoteCards(
            collectionUUID: currentSearchCollection?.uuid,
            searchText: searchText,
            searchFields: [.native, .translation],
            sortField: .translation
        )
        
        if fetchController == nil {
            fetchController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: appState.parentContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        } else {
            fetchController!.fetchRequest.predicate = request.predicate
            fetchController!.fetchRequest.sortDescriptors = request.sortDescriptors
        }
        
        try? fetchController!.performFetch()
        
        cardViewModel.noteCards = fetchController!.fetchedObjects ?? []
        cardViewModel.updateSnapshot(animated: true)
    }
}
    

struct NoteCardSearchView_Previews: PreviewProvider {
    static let appState = AppState(parentContext: .sample)
    static var previews: some View {
        NoteCardSearchView(appState: appState, onCancel: {})
    }
}
