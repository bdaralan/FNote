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
import CoreData


enum PublicCollectionQueryOption {
    case matchUsername
    case matchCollectionNameOrTag
}


struct PublicRecordSearchView: View {
    
    /// A context used to save public records to user's collections.
    var context: NSManagedObjectContext
    
    var onCancel: (() -> Void)?
    
    @State private var searchField = SearchField()
    
    @State private var isSearchFieldFirstResponder = true
    
    @State private var collectionViewModel = PublicRecordSearchCollectionViewModel()
    
    @State private var trayViewModel = BDButtonTrayViewModel()
    
    @State private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    @State private var searchOption: PublicCollectionQueryOption = .matchCollectionNameOrTag
    
    /// The fetch operation in progress.
    ///
    /// The view updates this value by observing `fetchingPublisher`.
    @State private var currentFetchOperation: CKQueryOperation?
    
    @State private var collectionToShowDetail: PublicCollection?
    @State private var showCollectionDetail = false
    
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .imageScale(.large)
                    .foregroundColor(Color(.placeholderText))
                
                BDTextFieldWrapper(
                    isActive: $isSearchFieldFirstResponder,
                    text: $searchField.searchText,
                    placeholder: searchField.placeholder,
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
            
            CollectionViewWrapper(viewModel: collectionViewModel, collectionView: collectionView)
                .edgesIgnoringSafeArea(.all)
        }
        .onAppear(perform: setupOnAppear)
        .overlay(BDButtonTrayView(viewModel: trayViewModel).padding(16), alignment: .bottomTrailing)
        .sheet(isPresented: $showCollectionDetail, content: collectionDetailView)
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
            self.presentCollectionDetailView(for: collection)
        }
    }
    
    func setupTrayViewModel() {
        trayViewModel.setDefaultColors()
        trayViewModel.shouldDisableMainItemWhenExpanded = false
        
        trayViewModel.mainItem = .init(title: "", systemImage: SFSymbol.search) { item in
            self.isSearchFieldFirstResponder = true
        }
        
        let searchByUser = BDButtonTrayItem(title: "Match username", systemImage: SFSymbol.matchByUsername) { item in
            self.searchOption = .matchUsername
            self.setTrayFocusedItem(item)
        }
        
        let searchByAny = BDButtonTrayItem(title: "Match name or tag", systemImage: SFSymbol.matchByAny) { item in
            self.searchOption = .matchCollectionNameOrTag
            self.setTrayFocusedItem(item)
        }
        
        trayViewModel.items = [searchByUser, searchByAny]
        trayViewModel.mainItem.inactiveColor = .appAccent
        setTrayFocusedItem(searchByAny)
    }
    
    func setTrayFocusedItem(_ focused: BDButtonTrayItem) {
        for item in trayViewModel.items {
            item.activeColor = item === focused ? .appAccent : .buttonTrayItemUnfocused
        }
        beginSearch(searchText: searchField.searchText)
    }
    
    func setTrayState(isSearching: Bool) {
        trayViewModel.mainItem.disabled = isSearching
        trayViewModel.mainItem.animation = isSearching ? .pulse() : nil
        trayViewModel.mainItem.title = isSearching ? "Searching..." : ""
    }
    
    func setupSearchField() {
        searchField.searchText = ""
        searchField.placeholder = "Search collection by name, tag, username..."
        searchField.setupSearchTextDebounce(dueTime: .seconds(0.5))
        
        searchField.onSearchTextDebounced = { searchText in
            self.beginSearch(searchText: searchText)
        }
    }
    
    func configureSearchTextField(_ textField: UITextField) {
        textField.font = .preferredFont(forTextStyle: .body)
        textField.autocapitalizationType = .none // TODO: remove this on release
        textField.clearButtonMode = .always
    }
}


// MARK: - Detail View

extension PublicRecordSearchView {
    
    func collectionDetailView() -> some View {
        guard let collection = collectionToShowDetail else {
            fatalError("🧨 attempted to present collection detail without assign a collection 🧨")
        }
        
        return PublicCollectionDetailView(
            collection: collection,
            context: context,
            onDismiss: dismissCollectionDetailView
        )
    }
    
    func presentCollectionDetailView(for collection: PublicCollection) {
        collectionToShowDetail = collection
        showCollectionDetail = true
    }
    
    func dismissCollectionDetailView() {
        collectionToShowDetail = nil
        showCollectionDetail = false
    }
}


// MARK: - Handler

extension PublicRecordSearchView {
    
    func handleSearchReturnKey() {
        beginSearch(searchText: searchField.searchText)
        isSearchFieldFirstResponder = false
    }
    
    func beginSearch(searchText: String) {
        let searchText = searchText.trimmed()
        
        currentFetchOperation?.cancel()
        
        // show searching animation if still fetching after a short while
        // do this because user does not need to see searching animation if the search is super quick
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard self.currentFetchOperation?.isFinished == false else { return }
            self.setTrayState(isSearching: true)
        }
        
        if searchText.isEmpty {
            collectionViewModel.collections = []
            collectionViewModel.updateSnapshot(animated: false)
            setTrayState(isSearching: false)
            return
        }
        
        currentFetchOperation = fetchPublicCollection(searchText: searchText) { results in
            var closelyMatchedCollections: [PublicCollection] = []
            
            var matchedCollections = results.compactMap { record -> PublicCollection? in
                let collection = PublicCollection(record: record)
                
                let matchingField: String
                switch self.searchOption {
                case .matchUsername: matchingField = collection.authorName
                case .matchCollectionNameOrTag: matchingField = collection.name
                }
                
                if matchingField.range(of: searchText, options: .caseInsensitive) != nil {
                    closelyMatchedCollections.append(collection)
                    return nil
                }
                
                return collection
            }
            
            closelyMatchedCollections.sort(by: { $0.name < $1.name })
            matchedCollections.sort(by: { $0.name < $1.name })
            
            let collections = closelyMatchedCollections + matchedCollections
            
            DispatchQueue.main.async {
                print("found: \(results.count) filtered: \(collections.count) searchText: \(searchText)")
                self.collectionViewModel.collections = collections
                self.collectionViewModel.updateSnapshot(animated: true, completion: nil)
                self.setTrayState(isSearching: false)
            }
        }
    }
}


// MARK: - Fetching

extension PublicRecordSearchView {
    
    func fetchPublicCollection(searchText: String, completion: @escaping ([CKRecord]) -> Void) -> CKQueryOperation {
        // CloudKit query documentation
        // https://developer.apple.com/documentation/cloudkit/ckquery#1965781
        
        let database = CKContainer.default().publicCloudDatabase
        
        var matchedRecords = [String: CKRecord]() // [recordName: CKRecord]
        
        let recordType = PublicCollection.recordType
        let authorNameField = PublicCollection.RecordFields.authorName.stringValue
        let collectionNameField = PublicCollection.RecordFields.name.stringValue
        
        let tokenPredicate = NSPredicate(format: "SELF CONTAINS %@", searchText)
        let tokenQuery = CKQuery(recordType: recordType, predicate: tokenPredicate)
        let tokenOP = CKQueryOperation(query: tokenQuery)
        
        let authorNamePredicate = NSPredicate(format: "\(authorNameField) BEGINSWITH %@", searchText)
        let authorNameQuery = CKQuery(recordType: recordType, predicate: authorNamePredicate)
        let authorNameOP = CKQueryOperation(query: authorNameQuery)
        
        let collectionNamePredicate = NSPredicate(format: "\(collectionNameField) BEGINSWITH %@", searchText)
        let collectionNameQuery = CKQuery(recordType: recordType, predicate: collectionNamePredicate)
        let collectionNameOP = CKQueryOperation(query: collectionNameQuery)
        
        let queryOperations = [tokenOP, authorNameOP, collectionNameOP]
        
        let completionOP = CKQueryOperation()
        completionOP.qualityOfService = .userInitiated
        
        completionOP.completionBlock = {
            if completionOP.isCancelled {
                queryOperations.forEach({ $0.cancel() })
            } else {
                let records = matchedRecords.values.map({ $0 })
                completion(records)
            }
        }
        
        for operation in queryOperations {
            completionOP.addDependency(operation)
            operation.qualityOfService = completionOP.qualityOfService
            operation.recordFetchedBlock = {
                matchedRecords[$0.recordID.recordName] = $0
            }
        }
        
        database.add(tokenOP)
        database.add(authorNameOP)
        database.add(collectionNameOP)
        database.add(completionOP)
        
        return completionOP
    }
}


struct PublishRecordSearchView_Previews: PreviewProvider {
    static var previews: some View {
        PublicRecordSearchView(context: .sample, onCancel: {})
    }
}
