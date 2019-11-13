//
//  SearchTextField.swift
//  ShoB
//
//  Created by Dara Beng on 8/7/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import Combine


/// A search text box.
struct SearchTextField: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var searchField: SearchField
    
    @ObservedObject var searchOption = SearchOption()
    
    var onEditingChanged: ((Bool) -> Void)?
    
    var onCancel: (() -> Void)?
    
    @State private var isEditing = false
    
    @State private var showSearchOption = false
    
    var isActive: Bool {
        isEditing || !searchField.searchText.isEmpty
    }
    
    let animationDuration = 0.3
    
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                HStack {
                    searchIcon
                    textField
                    if !searchOption.options.isEmpty && isActive {
                        searchOptionButton
                            .transition(.scale)
                            .animation(.easeInOut(duration: animationDuration))
                    }
                }
                .padding(8)
                .background(Color(UIColor(white: colorScheme == .light ? 0.92 : 0.1, alpha: 1)))
                .cornerRadius(10)
                
                // show cancel button when the search is editing or there is text
                if isActive {
                    cancelButton
                        .transition(.scale)
                        .animation(.easeInOut(duration: animationDuration))
                }
            }
            .animation(.easeInOut(duration: animationDuration))
            
            if showSearchOption {
                searchOptionView
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut(duration: animationDuration))
                    .zIndex(-1)
            }
        }
        .animation(.easeInOut(duration: animationDuration))
    }
}


// MARK: - View Component

extension SearchTextField {
    
    var searchIcon: some View {
        Image(systemName: "magnifyingglass")
            .foregroundColor(.secondary)
    }
    
    var textField: some View {
        TextField(
            searchField.placeholder,
            text: $searchField.searchText,
            onEditingChanged: searchTextFieldEditingChanged
        )
    }
    
    var searchOptionButton: some View {
        Button(action: { self.showSearchOption.toggle() }) {
            Image(systemName: "slider.horizontal.3")
        }
    }
    
    var cancelButton: some View {
        Button("Cancel", action: cancelSearch)
            .foregroundColor(.accentColor)
    }
    
    var searchOptionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(searchOption.options, id: \.self) { option in
                    self.searchOptionText(
                        option: option,
                        selected: self.searchOption.selectedOptions.contains(option)
                    )
                        .animation(.easeInOut(duration: 0.2))
                        .onTapGesture(perform: { self.searchOption.handleSelection(option: option) })
                }
            }
        }
    }
    
    func searchOptionText(option: String, selected: Bool) -> some View {
        Text(option)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .font(.callout)
            .foregroundColor(.primary)
            .background(Color.tagScrollPillBackground)
            .cornerRadius(20)
            .overlay(Capsule(style: .circular).stroke(Color.appAccent, lineWidth: selected ? 2 : 0))
            .padding(2)
    }
}


// MARK: - Method

extension SearchTextField {
    
    func cancelSearch() {
        searchField.cancel()
        searchField.clear()
        showSearchOption = false
        onCancel?()
    }
    
    func searchTextFieldEditingChanged(_ isEditing: Bool) {
        self.isEditing = isEditing
        onEditingChanged?(isEditing)
        if !isEditing, searchField.searchText.isEmpty {
            cancelSearch()
        }
    }
}


// MARK: - SearchField Model

/// An observable object used with `SearchTextField` to handle search.
///
/// The object provides actions to perform when text changed or debounced.
class SearchField: ObservableObject {
    
    @Published var searchText = "" {
        didSet { onSearchTextChanged?(searchText) }
    }
    
    var placeholder = "Search"
    
    /// An action to perform when text changed.
    var onSearchTextChanged: ((String) -> Void)?
    
    /// An action to perform when debounce text changed.
    var onSearchTextDebounced: ((String) -> Void)?
    
    private var searchTextDebounceCancellable: AnyCancellable?
    
    
    init() {
        searchTextDebounceCancellable = $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { newValue in
                self.objectWillChange.send()
                self.onSearchTextDebounced?(newValue)
            })
    }
    
    
    /// Clear the search text.
    func clear() {
        searchText = ""
    }
    
    /// Ask the application to resign the first responder, which is the keyboard.
    func cancel() {
        let dismissKeyboard = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(dismissKeyboard, to: nil, from: nil, for: nil)
    }
}


// MARK: - SearchOption Model

/// An observable object used with `SearchTextField` to handle search options.
class SearchOption: ObservableObject {
    
    @Published var options = [String]()
    
    @Published var selectedOptions = [String]()
    
    var allowsMultipleSelections = false
    
    var allowsEmptySelection = true
    
    var selectedOptionsChanged: (() -> Void)?
    
    func handleSelection(option: String) {
        if let index = selectedOptions.firstIndex(of: option) { // deselect
            if !allowsEmptySelection, selectedOptions.count == 1 {
                return
            }
            selectedOptions.remove(at: index)
            selectedOptionsChanged?()
        
        } else { // select
            if allowsMultipleSelections {
                selectedOptions.append(option)
            } else {
                selectedOptions = [option]
            }
            selectedOptionsChanged?()
        }
    }
}


struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
        SearchTextField(searchField: .init())
    }
}
