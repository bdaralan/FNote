//
//  NoteCardSearchModel.swift
//  FNote
//
//  Created by Dara Beng on 11/10/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


/// A view model used to handle searching note card.
class NoteCardSearchModel: ObservableObject {
    
    /// The context used to fetch the note card.
    ///
    /// Set the context before attempt to handle any searches.
    /// If this value is `nil`, the fetch will not perform.
    var context: NSManagedObjectContext?
    
    /// A fetch controller for the search result.
    ///
    /// - Important:
    ///   - Initialize its value to tell the view that it is in searching state.
    ///   - Make sure to set the value back to `nil` to tell the view that it is not in searching state.
    ///   - Use the computed property `isActive` when want to check the state.
    private(set) var searchFetchResult: NSFetchedResultsController<NoteCard>?
    
    @Published private(set) var searchField: SearchField
    
    @Published private(set) var searchOption: SearchOption
    
    /// A note cards to be used as a search results.
    @Published private(set) var manualSearchResults = [NoteCard]()
    
    /// A flag used to indicate whether to show the search results.
    @Published private(set) var isManualSearchResultsActive = false
    
    /// A search option when performing search.
    ///
    /// The default is empty which means match all note cards.
    var noteCardSearchOptions = [NoteCardSearchOption]()
    
    /// A constraint when performing search.
    ///
    /// The default is `nil` which means match all note cards.
    /// Assign a collection's UUID to match only those in that collection.
    var matchingCollectionUUID: String?
    
    var isActive: Bool {
        searchFetchResult != nil || isManualSearchResultsActive
    }
    
    /// The objects matched the search condition.
    ///
    /// Returns the search results or
    var searchResults: [NoteCard] {
        isManualSearchResultsActive ? manualSearchResults : searchFetchResult?.fetchedObjects ?? []
    }
    
    
    init() {
        searchField = SearchField()
        searchOption = SearchOption()
        setupSearchField()
        setupSearchOption()
    }
    
    
    func reset() {
        searchFetchResult = nil
        manualSearchResults = []
        isManualSearchResultsActive = false
        setupSearchOption()
    }
    
    func setManualResults(noteCards: [NoteCard]) {
        objectWillChange.send()
        
        let results = noteCards.compactMap({ context?.object(with: $0.objectID) as? NoteCard })
        manualSearchResults = results
        isManualSearchResultsActive = !results.isEmpty
        setupSearchOption()
        searchField.searchText = searchOption.selectedOptions.first ?? "lookup mode | active"
    }
    
    func refetchNoteCards() {
        fetchNoteCards(searchText: searchField.searchText)
    }
}


// MARK: - Setup & Fetch

extension NoteCardSearchModel {
    
    private func setupSearchField() {
        searchField.onSearchTextDebounced = { [weak self] searchText in
            guard let self = self else { return }
            guard !self.isManualSearchResultsActive else {
                if searchText.isEmpty {
                    self.searchField.cancel()
                }
                return
            }
            self.fetchNoteCards(searchText: searchText)
        }
    }
    
    private func setupSearchOption() {
        let searchOptions: [String]
        let selectedOptions: [String]
        
        if isManualSearchResultsActive {
            searchOptions = ["lookup mode | active"]
            selectedOptions = searchOptions
        } else {
            let options = [NoteCardSearchScope.translationOrNative, .note, .tag, .translation, .native]
            searchOptions = options.map({ $0.title })
            selectedOptions = [searchOptions.first!]
        }
        
        searchOption.options = searchOptions
        searchOption.selectedOptions = selectedOptions
        searchOption.allowsMultipleSelections = false
        searchOption.allowsEmptySelection = false
        
        searchOption.selectedOptionsChanged = { [weak self] in
            guard let self = self else { return }
            self.fetchNoteCards(searchText: self.searchField.searchText)
        }
    }
    
    private func fetchNoteCards(searchText: String) {
        objectWillChange.send()
        
        guard let context = context, !searchText.trimmed().isEmpty else {
            searchFetchResult = nil
            return
        }
        
        // initialize searchFetchResult when start searching
        // only does so if there is text in the search text field
        // this prevents unnecessary fetching in the case where user
        // activates the search but then cancels right away
        if searchFetchResult == nil {
            searchFetchResult = .init(
                fetchRequest: NoteCard.requestNone(),
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
        }
        
        // being fetching with the search text if searchFetchResult is initialized.
        guard let searchFetchResult = searchFetchResult else { return }
        
        // safe to unwrapped here because already setup to always have one option
        // see setupSearchTextField() method
        let searchScope = NoteCardSearchScope.scope(withTitle: searchOption.selectedOptions.first!)!
        
        let request = NoteCard.requestNoteCards(
            forCollectionUUID: matchingCollectionUUID,
            search: searchText,
            scope: searchScope,
            options: noteCardSearchOptions
        )
        
        searchFetchResult.fetchRequest.predicate = request.predicate
        searchFetchResult.fetchRequest.sortDescriptors = request.sortDescriptors
        try? searchFetchResult.performFetch()
    }
}
