//
//  SearchField.swift
//  FNote
//
//  Created by Dara Beng on 8/7/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation
import Combine


/// An observable object used with `SearchTextField` to handle search.
///
/// The object provides actions to perform when text changed or debounced.
class SearchField: ObservableObject {
    
    @Published var searchText = ""
    
    @Published var placeholder = "Search"
    
    /// An action to perform when the `searchText` debounced.
    var onSearchTextDebounced: ((String) -> Void)?
    
    private var searchTextDebounce: AnyCancellable!
    
    
    init() {
        setupSearchTextDebounce()
    }
    
    
    /// Set `searchText`'s debounce time.
    ///
    /// - Parameter dueTime: The debounced time.
    func setupSearchTextDebounce(dueTime: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(500)) {
        searchTextDebounce = $searchText.eraseToAnyPublisher()
            .debounce(for: dueTime, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] newValue in
                self?.onSearchTextDebounced?(newValue)
            })
    }
}
