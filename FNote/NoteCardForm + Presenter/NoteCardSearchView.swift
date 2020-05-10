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
    @State private var fetchController: NSFetchedResultsController<NoteCard>?
    
    @State private var trayViewModel = BDButtonTrayViewModel()
    
    @State private var currentSearchCollectionID: String?
    @State private var cardViewModel = NoteCardCollectionViewModel()
    @State private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
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
            
            CollectionViewWrapper(viewModel: cardViewModel, collectionView: collectionView)
                .edgesIgnoringSafeArea(.all)
        }
        .onAppear(perform: setupOnAppear)
        .overlay(BDButtonTrayView(viewModel: trayViewModel).padding(16), alignment: .bottomTrailing)
    }
}


// MARK: - Setup

extension NoteCardSearchView {
    
    func setupOnAppear() {
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
        trayViewModel.mainItem = .init(title: "", systemImage: SFSymbol.search) { item in
            self.isSearchFieldFirstResponder = true
        }
    }
    
    func createTrayItems() -> [BDButtonTrayItem] {
        var searchCurrent: BDButtonTrayItem!
        var searchAll: BDButtonTrayItem!
        
        let redoSearchAndCollapseTray = {
            // set a tiny delay to let user sees the item's state changed before the tray is collapsed
            self.updateSearchState(searchCurrent: searchCurrent, searchAll: searchAll)
            self.beginSearch(searchText: self.searchField.searchText)
            self.cardViewModel.scrollToTop(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                self.trayViewModel.expanded = false
            }
        }
        
        searchCurrent = BDButtonTrayItem(title: "Search current collection", systemImage: "") { item in
            self.currentSearchCollectionID = self.appState.currentCollectionID
            redoSearchAndCollapseTray()
        }
        
        searchAll = BDButtonTrayItem(title: "Search all collections", systemImage: "") { item in
            self.currentSearchCollectionID = nil
            redoSearchAndCollapseTray()
        }
        
        updateSearchState(searchCurrent: searchCurrent, searchAll: searchAll)
        
        return [searchCurrent, searchAll]
    }
    
    func updateSearchState(searchCurrent: BDButtonTrayItem, searchAll: BDButtonTrayItem) {
        let selectedImage = SFSymbol.selectedOption
        let unselectedImage = SFSymbol.option
        let selectedColor = Color.appAccent
        let unselectedColor = Color.buttonTrayItemUnfocused
        
        if currentSearchCollectionID == nil { // search all
            searchAll.systemImage = selectedImage
            searchAll.activeColor = selectedColor
            searchCurrent.systemImage = unselectedImage
            searchCurrent.activeColor = unselectedColor
            searchFieldPlaceholder = searchAll.title
        } else { // search current
            searchCurrent.systemImage = selectedImage
            searchCurrent.activeColor = selectedColor
            searchAll.systemImage = unselectedImage
            searchAll.activeColor = unselectedColor
            searchFieldPlaceholder = searchCurrent.title
        }
    }
    
    func beginSearch(searchText: String) {
        if searchText.trimmed().isEmpty {
            fetchController = nil
            let noteCards = currentSearchCollectionID == nil ? [] : appState.currentNoteCards
            cardViewModel.noteCards = noteCards
            cardViewModel.updateSnapshot(animated: true)
            return
        }
        
        let request = NoteCard.requestNoteCards(
            collectionUUID: currentSearchCollectionID,
            searchText: searchText,
            searchFields: [.native, .translation],
            sortBy: .translation
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
