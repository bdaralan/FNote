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
    
    /// A flag indicate the search is editing or there is text.
    var isActive: Bool {
        isEditing || !searchField.searchText.isEmpty
    }
    
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                HStack {
                    searchIcon
                    textField
                    
                    if !searchOption.options.isEmpty && isActive {
                        searchOptionButton
                    }
                }
                .padding(8)
                .background(searchBackground)
                
                if isActive {
                    cancelButton
                }
            }
            
            if showSearchOption {
                searchOptionView
            }
        }
    }
}


// MARK: - View Component

extension SearchTextField {
    
    var searchBackground: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color(white: colorScheme == .light ? 0.92 : 0.1))
    }
    
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
        .transition(AnyTransition.scale.animation(.easeInOut))
    }
    
    var cancelButton: some View {
        Button("Cancel", action: cancelSearch)
            .foregroundColor(.accentColor)
            .transition(AnyTransition.scale.animation(.easeInOut))
    }
    
    var searchOptionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(searchOption.options, id: \.self) { option in
                    self.searchOptionText(option: option)
                }
            }
        }
    }
    
    func searchOptionText(option: String) -> some View {
        let isSelected = searchOption.selectedOptions.contains(option)
        let border = Capsule(style: .circular).stroke(Color.appAccent, lineWidth: isSelected ? 2 : 0)
        let tapAction = {
            self.searchOption.handleSelection(option: option)
        }
        return Text(option)
            .padding(.vertical, 6)
            .padding(.horizontal, 16)
            .font(.callout)
            .foregroundColor(.primary)
            .background(Color.tagScrollPillBackground)
            .cornerRadius(20)
            .overlay(border)
            .padding(2)
            .animation(.easeInOut)
            .onTapGesture(perform: tapAction)
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
    
    private var cancellables: [AnyCancellable] = []
    
    
    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { newValue in
                self.objectWillChange.send()
                self.onSearchTextDebounced?(newValue)
            })
            .store(in: &cancellables)
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
