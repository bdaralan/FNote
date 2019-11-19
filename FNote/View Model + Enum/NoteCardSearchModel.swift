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
    
    var isActive: Bool {
        searchFetchResult != nil
    }
    
    
    init() {
        searchField = SearchField()
        searchOption = SearchOption()
        setupSearchField()
        setupSearchOption()
    }
    
    
    func deactivate() {
        searchFetchResult = nil
        searchOption.selectedOptions = [searchOption.options.first!]
    }
}


// MARK: - Setup & Fetch

extension NoteCardSearchModel {
    
    private func setupSearchField() {
        searchField.onSearchTextDebounced = { [weak self] searchText in
            guard let self = self else { return }
            self.fetchNoteCards(searchText: searchText)
        }
    }
    
    private func setupSearchOption() {
        let options = [NoteCardSearchScope.translationOrNative, .note, .tag, .translation, .native]
        searchOption.options = options.map({ $0.title })
        searchOption.selectedOptions = [searchOption.options.first!]
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
        
        guard let collectionUUID = AppCache.currentCollectionUUID else {
            // cancel the search if cannot get current collection ID
            deactivate()
            searchField.cancel()
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
            forCollectionUUID: collectionUUID,
            searchText: searchText,
            scope: searchScope
        )
        
        searchFetchResult.fetchRequest.predicate = request.predicate
        searchFetchResult.fetchRequest.sortDescriptors = request.sortDescriptors
        try? searchFetchResult.performFetch()
    }
}
