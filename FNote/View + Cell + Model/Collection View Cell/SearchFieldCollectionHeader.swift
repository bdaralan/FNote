//
//  SearchFieldCollectionHeader.swift
//  FNote
//
//  Created by Dara Beng on 1/25/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit
import Combine


class SearchFieldCollectionHeader: UICollectionReusableView {
        
    let searchField = UISearchTextField()
    let cancelButton = UIButton(type: .system)
    let noteButton = UIButton(type: .system)
    
    private let fieldHStack = UIStackView()
    
    var searchText: String {
        set { searchField.text = newValue }
        get { searchField.text ?? "" }
    }
    
    var onCancel: (() -> Void)?
    var onSearch: (() -> Void)?
    var onSearchTextDebounced: ((String) -> Void)?
    var onSearchTextChanged: ((String) -> Void)?
    var onEditingChanged: ((Bool) -> Void)?
    var onNoteActive: ((Bool) -> Void)?
    
    @Published private var debounceSearchText = ""
    
    @Published private(set) var isNoteActive = false
    
    private var cancellables: [AnyCancellable] = []
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        setupTargets()
        setupSearchTextSubscription()
        setupNoteActiveSubscription()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showCancel(_ show: Bool, animated: Bool) {
        cancelButton.isHidden = !show
        noteButton.isHidden = !show || onNoteActive == nil
        UIView.animate(withDuration: animated ? 0.3 : 0) { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
        }
    }
    
    func setDebounceSearchText(_ text: String) {
        debounceSearchText = text
    }
}


extension SearchFieldCollectionHeader: UISearchTextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.resignFirstResponder()
        onSearch?()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showCancel(true, animated: true)
        onEditingChanged?(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        onEditingChanged?(false)
        if searchText.trimmed().isEmpty {
            searchText = ""
            debounceSearchText = ""
            showCancel(false, animated: true)
        }
    }
}


extension SearchFieldCollectionHeader {
    
    private func setupView() {
        searchField.delegate = self
        searchField.placeholder = "Search"
        searchField.returnKeyType = .search
        searchField.backgroundColor = UIColor.noteCardBackground?.withAlphaComponent(0.4)
        
        cancelButton.isHidden = true
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.appAccent, for: .normal)
    
        noteButton.isHidden = true
        let noteImage = UIImage(systemName: "doc.plaintext", withConfiguration: nil)
        noteButton.setImage(noteImage, for: .normal)
    }
    
    private func setupConstraints() {
        fieldHStack.addArrangedSubviews(searchField, noteButton, cancelButton)
        fieldHStack.axis = .horizontal
        fieldHStack.distribution = .fill
        fieldHStack.spacing = 12
        
        addSubviews(fieldHStack, useAutoLayout: true)
        
        NSLayoutConstraint.activateConstraints(
            fieldHStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            fieldHStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            fieldHStack.widthAnchor.constraint(equalTo: widthAnchor),
            fieldHStack.heightAnchor.constraint(equalToConstant: 35)
        )
    }
    
    private func setupSearchTextSubscription() {
        $debounceSearchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] newValue in
                self?.onSearchTextDebounced?(newValue)
            })
            .store(in: &cancellables)
    }
    
    private func setupNoteActiveSubscription() {
        $isNoteActive
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isActive in
                self?.noteButton.tintColor = isActive ? .appAccent : .secondaryLabel
            })
            .store(in: &cancellables)
    }
    
    private func setupTargets() {
        searchField.addTarget(self, action: #selector(handleTextChanged), for: .editingChanged)
        cancelButton.addTarget(self, action: #selector(handleCancelButtonTapped), for: .touchUpInside)
        noteButton.addTarget(self, action: #selector(handleOptionButtonTapped), for: .touchUpInside)
    }
    
    @objc private func handleCancelButtonTapped() {
        onCancel?()
    }
    
    @objc private func handleOptionButtonTapped() {
        isNoteActive.toggle()
        onNoteActive?(isNoteActive)
    }
    
    @objc private func handleTextChanged() {
        let text = searchField.text ?? ""
        onSearchTextChanged?(text)
        debounceSearchText = text
    }
}
