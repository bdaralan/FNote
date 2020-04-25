//
//  PublicRecordSearchView.swift
//  FNote
//
//  Created by Dara Beng on 4/23/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit
import CloudKit
import Combine


enum PublicCollectionQueryOption {
    case matchUsername
    case matchCollectionNameOrTag
}


struct PublicRecordSearchView: View {
    
    @State private var searchField = SearchField()
    
    @State private var isSearchFieldFirstResponder = true
    
    @State private var collectionViewModel = PublicRecordSearchCollectionViewModel()
    
    @State private var trayViewModel = BDButtonTrayViewModel()
    
    @State private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    @State private var searchOption: PublicCollectionQueryOption = .matchCollectionNameOrTag
    
    /// A publisher to notify that a search has started.
    ///
    /// The view observers this publisher and calls `handleFetchingPublisher(_:)`.
    ///
    /// Send an operation to indicate fetching in process or `nil` to indicate canceled.
    @State private var fetchingPublisher = PassthroughSubject<CKQueryOperation?, Never>()
    
    /// The fetch operation in progress.
    ///
    /// The view updates this value by observing `fetchingPublisher`.
    @State private var fetchingOperation: CKQueryOperation?
    
    
    var body: some View {
        VStack(spacing: 0) {
            BDTextFieldWrapper(
                isActive: $isSearchFieldFirstResponder,
                text: $searchField.searchText,
                placeholder: searchField.placeholder,
                returnKeyType: .search,
                onCommit: handleSearchReturnKey,
                configure: configureSearchTextField
            )
                .frame(height: 60)
                .padding(.horizontal, 16)
                .overlay(BDModalDragHandle(hideOnVerticalCompact: true).padding(.top, 8), alignment: .top)
            
            Divider()
            
            CollectionViewWrapper(viewModel: collectionViewModel, collectionView: collectionView)
                .edgesIgnoringSafeArea(.all)
        }
        .overlay(BDButtonTrayView(viewModel: trayViewModel).padding(16), alignment: .bottomTrailing)
        .onAppear(perform: setupOnAppear)
        .onReceive(fetchingPublisher.receive(on: DispatchQueue.main), perform: handleFetchingPublisher)
    }
}


// MARK: - Setup

extension PublicRecordSearchView {
    
    func setupOnAppear() {
        setupCollectionViewModel()
        setupTrayViewModel()
        setupSearchField()
    }
    
    func setupCollectionViewModel() {
        collectionViewModel.setupCollectionView(collectionView)
        collectionViewModel.updateSnapshot(animated: false, completion: nil)
        
        collectionViewModel.onCollectionSelected = { collection in
            print(collection)
        }
    }
    
    func setupTrayViewModel() {
        trayViewModel.setDefaultColors()
        
        trayViewModel.items = createTrayItems()
        setTrayFocusedItem(trayViewModel.items[1]) // it must work
        
        trayViewModel.shouldDisableMainItemWhenExpanded = false
        
        trayViewModel.mainItem = .init(title: "", systemImage: "magnifyingglass") { item in
            if self.isSearchFieldFirstResponder {
                let currentSearchText = self.searchField.searchText
                self.beginSearch(searchText: currentSearchText)
            } else {
                self.isSearchFieldFirstResponder = true
            }
        }
    }
    
    func createTrayItems() -> [BDButtonTrayItem] {
        let searchByUser = BDButtonTrayItem(title: "Match username", systemImage: "person.circle") { item in
            self.searchOption = .matchUsername
            self.setTrayFocusedItem(item)
        }
        
        let searchByAny = BDButtonTrayItem(title: "Match name or tag", systemImage: "doc.text.magnifyingglass") { item in
            self.searchOption = .matchCollectionNameOrTag
            self.setTrayFocusedItem(item)
        }
        
        return [searchByUser, searchByAny]
    }
    
    func setTrayFocusedItem(_ focused: BDButtonTrayItem) {
        for item in trayViewModel.items {
            item.activeColor = item === focused ? .appAccent : .buttonTrayItemUnfocused
        }
        beginSearch(searchText: searchField.searchText)
    }
    
    func setupSearchField() {
        searchField.placeholder = "Search collection by name, tag, or language..."
        
        searchField.onSearchTextDebounced = { searchText in
            self.beginSearch(searchText: searchText)
        }
    }
    
    func configureSearchTextField(_ textField: UITextField) {
        textField.font = .preferredFont(forTextStyle: .body)
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .always
    }
}


// MARK: - Handler

extension PublicRecordSearchView {
    
    func handleSearchReturnKey() {
        beginSearch(searchText: searchField.searchText)
        isSearchFieldFirstResponder = false
    }
    
    func handleFetchingPublisher(operation: CKQueryOperation?) {
        // cancel the current operation if any
        if let currentOperation = fetchingOperation {
            currentOperation.cancel()
        }
        
        fetchingOperation = operation
        trayViewModel.mainItem.disabled = operation != nil
    }
    
    func beginSearch(searchText: String) {
        let searchText = searchText.trimmed()
        
        if searchText.isEmpty {
            fetchingPublisher.send(nil)
            collectionViewModel.collections = []
            collectionViewModel.updateSnapshot(animated: true, completion: nil)
            return
        }
        
        // if searching in progress, ignore
        guard fetchingOperation == nil else { return }
        
        let operation = fetchPublicCollection(searchText: searchText) { result in
            switch result {
            case .success(let records):
                let collections = records.compactMap { record -> PublicCollection? in
                    let collection = PublicCollection(record: record)
                    if self.searchOption == .matchUsername {
                        if collection.authorName.range(of: searchText, options: .caseInsensitive) != nil {
                            return collection
                        } else {
                            return nil
                        }
                    } else {
                        return collection
                    }
                }
                
                DispatchQueue.main.async {
                    self.collectionViewModel.collections = collections
                    self.collectionViewModel.updateSnapshot(animated: true, completion: nil)
                    self.fetchingPublisher.send(nil)
                }
                print("found: \(records.count) filtered: \(collections.count)")
                
            case .failure(let error):
                print("search error: \(error)")
                DispatchQueue.main.async {
                    self.fetchingPublisher.send(nil)
                }
            }
        }
        
        fetchingPublisher.send(operation)
    }
}


// MARK: - Fetching

extension PublicRecordSearchView {
    
    func fetchPublicCollection(searchText: String, completion: @escaping (Result<[CKRecord], CKError>) -> Void) -> CKQueryOperation {
        // https://developer.apple.com/documentation/cloudkit/ckquery#1965781
        
        let database = CKContainer.default().publicCloudDatabase
        
        let predicate = NSPredicate(format: "self contains %@", searchText)
        let query = CKQuery(recordType: PublicCollection.recordType, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        var matchedRecords = [CKRecord]()
        
        operation.recordFetchedBlock = { record in
            matchedRecords.append(record)
        }
        
        operation.queryCompletionBlock = { cursor, error in
            if let error = error {
                completion(.failure(error as! CKError))
            } else {
                completion(.success(matchedRecords))
            }
        }
        
        operation.qualityOfService = .userInitiated
        
        database.add(operation)
        
        return operation
    }
}


struct PublishRecordSearchView_Previews: PreviewProvider {
    static var previews: some View {
        Color.clear.sheet(isPresented: .constant(true)) {
            PublicRecordSearchView()
        }
    }
}



