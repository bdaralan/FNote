//
//  NoteCardCollectionViewModel.swift
//  FNote
//
//  Created by Dara Beng on 1/19/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class NoteCardCollectionViewModel: NSObject, CollectionViewCompositionalDataSource {
    
    typealias DataSourceSection = Section
    typealias DataSourceItem = NoteCard
    
    enum Section {
        case search
        case card
    }
    
    
    // MARK: Property
    
    var noteCards: [NoteCard] = []
    
    var dataSource: DiffableDataSource!
    
    var cellStyle: NoteCardCell.Style = .regular
    
    /// A set of IDs indicate that cells should be bordered.
    var borderedNoteCardIDs: Set<String> = []
    
    /// A set of IDs indicate that cells should be disabled.
    var disableNoteCardIDs: Set<String> = []
    
    /// A set of IDs that should ignore selection.
    ///
    /// `onNoteCardSelected` will not be called.
    var ignoreSelectionNoteCardIDs: Set<String> = []
    
    /// Context menus to be shown.
    var contextMenus: [NoteCardCell.ContextMenu] = []
    
    private var sections: [Section] {
        onSearchTextDebounced == nil ? [.card] : [.search, .card]
    }
    
    
    // MARK: Action
    
    var onNoteCardSelected: ((NoteCard) -> Void)?
    var onNoteCardQuickButtonTapped: ((NoteCardCell.QuickButtonType, NoteCard) -> Void)?
    var onContextMenuSelected: ((NoteCardCell.ContextMenu, NoteCard) -> Void)?
    
    
    // MARK: Search
    var onSearchTextDebounced: ((String) -> Void)?
    var onSearchTextChanged: ((String) -> Void)?
    var onSearchCancel: (() -> Void)?
    var onSearchNoteActiveChanged: ((Bool) -> Void)?
    
    
    // MARK: Reference
    
    /// A reference to the collection view.
    private weak var collectionView: UICollectionView?
    
    /// A flag to reload cell quick buttons images if size category ever changed.
    private var sizeCategoryChanged = false
    
    /// Check if the search is active.
    ///
    /// - Note: The search is considered inactive if the search text is empty.
    private(set) var isSearchActive = false
    
    var searchFieldHeader: SearchFieldCollectionHeader? {
        let headerKind = UICollectionView.elementKindSectionHeader
        let header = collectionView?.visibleSupplementaryViews(ofKind: headerKind).first
        return header as? SearchFieldCollectionHeader
    }
    
    var isSearchNoteActive: Bool {
        searchFieldHeader?.isNoteActive ?? false
    }
    
    
    // MARK: Method
    
    func reloadedVisibleCells() {
        guard let collectionView = collectionView else { return }
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in visibleIndexPaths {
            let cell = collectionView.cellForItem(at: indexPath) as! NoteCardCell
            if let noteCard = dataSource.itemIdentifier(for: indexPath) {
                setupNoteCardCell(cell, for: noteCard)
            }
        }
    }
    
    /// The method does not trigger `onSearchCancel` block.
    func cancelSearch() {
        let headerIndexPath = IndexPath(item: 0, section: 0)
        let headerKind = UICollectionView.elementKindSectionHeader
        let supplementaryView = collectionView?.supplementaryView(forElementKind: headerKind, at: headerIndexPath)
        
        guard let header = supplementaryView as? SearchFieldCollectionHeader else { return }
        guard !header.searchText.isEmpty else { return }
        header.searchText = ""
        header.searchField.resignFirstResponder()
        header.showCancel(false, animated: true)
        header.setDebounceSearchText("")
    }
    
    private func setupNoteCardCell(_ cell: NoteCardCell, for noteCard: NoteCard) {
        cell.reload(with: noteCard)
        cell.setCellStyle(cellStyle)
        cell.showCellBorder(borderedNoteCardIDs.contains(noteCard.uuid))
        cell.disableCell(disableNoteCardIDs.contains(noteCard.uuid))
        cell.onQuickButtonTapped = onNoteCardQuickButtonTapped
        
        guard sizeCategoryChanged else { return }
        cell.setQuickButtonImages()
    }
    
    private func setupSearchHeader(_ header: SearchFieldCollectionHeader) {
        header.searchField.placeholder = "Search by native, translation, or note"
        
        header.onSearchTextChanged = { [weak self] searchText in
            guard let self = self else { return }
            self.isSearchActive = !searchText.trimmed().isEmpty
            self.onSearchTextChanged?(searchText)
        }
        
        header.onSearchTextDebounced = { [weak self] searchText in
            guard let self = self else { return }
            self.onSearchTextDebounced?(searchText)
        }
        
        header.onCancel = { [weak self] in
            guard let self = self else { return }
            self.onSearchCancel?()
            self.isSearchActive = false
            header.searchText = ""
            header.searchField.resignFirstResponder()
            header.showCancel(false, animated: true)
        }
        
        header.onNoteActive = { [weak self] isActive in
            guard let self = self else { return }
            self.onSearchNoteActiveChanged?(isActive)
        }
    }
    
    @objc private func handleSizeCategoryChanged() {
        sizeCategoryChanged = true
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot)
    }
}


// MARK: - Collection Delegate

extension NoteCardCollectionViewModel: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let noteCard = dataSource.itemIdentifier(for: indexPath) else { return }
        guard !ignoreSelectionNoteCardIDs.contains(noteCard.uuid) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? NoteCardCell else { return }
        onNoteCardSelected?(noteCard)
        cell.showCellBorder(borderedNoteCardIDs.contains(noteCard.uuid))
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard !contextMenus.isEmpty else { return nil }
        guard let noteCard = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return createContextMenuConfiguration(for: noteCard)
    }
}


// MARK: - Context Menu

extension NoteCardCollectionViewModel {
    
    private func createContextMenuConfiguration(for noteCard: NoteCard) -> UIContextMenuConfiguration? {
        let actions = contextMenus.map({ createContextMenuAction(for: $0, with: noteCard) })
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { someElement in
            UIMenu(title: "", options: .displayInline, children: actions)
        }
        return configuration
    }
    
    private func createContextMenuAction(for menu: NoteCardCell.ContextMenu, with noteCard: NoteCard) -> UIAction {
        let isDestructive = menu == .delete
        let attribute: UIMenuElement.Attributes = isDestructive ? .destructive : .init()
        let action = UIAction(title: menu.title, image: menu.image, attributes: attribute) { action in
            self.onContextMenuSelected?(menu, noteCard)
        }
        return action
    }
}


// MARK: - Collection Wrapper

extension NoteCardCollectionViewModel: CollectionViewWrapperViewModel {
    
    func setupCollectionView(_ collectionView: UICollectionView) {
        setupDataSource(with: collectionView)
        updateSnapshot(animated: false)
    }
}


// MARK: - Collection Diff Data Source

extension NoteCardCollectionViewModel {
    
    func updateSnapshot(animated: Bool, completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        
        for section in sections {
            switch section {
            case .search: snapshot.appendItems([], toSection: section)
            case .card: snapshot.appendItems(noteCards, toSection: section)
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
    }
    
    func setupDataSource(with collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.registerCell(NoteCardCell.self)
        collectionView.registerHeader(SearchFieldCollectionHeader.self)
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        listenToSizeCategoryChanged()
        
        // MARK: Cell
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, noteCard in
            switch self.sections[indexPath.section] {
            case .card:
                let cardCell = collectionView.dequeueCell(NoteCardCell.self, for: indexPath)
                self.setupNoteCardCell(cardCell, for: noteCard)
                return cardCell
                
            case .search:
                fatalError("🧨 attempt to dequeue cell for search section. 🧨")
            }
        }
        
        // MARK: Header
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            let searchHeader = collectionView.dequeueHeader(SearchFieldCollectionHeader.self, for: indexPath)
            self.setupSearchHeader(searchHeader)
            return searchHeader
        }
    }
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { section, environment in
            switch self.sections[section] {
            case .search: return self.createSearchLayoutSection()
            case .card: return self.createNoteCardLayoutSection()
            }
        }
        return layout
    }
    
    private func createNoteCardLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let height = cellStyle.height
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    private func createSearchLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [createSearchFieldSupplementaryItem()]
        
        return section
    }
    
    private func createSearchFieldSupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let kind = UICollectionView.elementKindSectionHeader
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(35 + 16))
        let item = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: kind, alignment: .top)
        item.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        return item
    }
    
    private func listenToSizeCategoryChanged() {
        let name = UIContentSizeCategory.didChangeNotification
        let action = #selector(handleSizeCategoryChanged)
        NotificationCenter.default.addObserver(self, selector: action, name: name, object: nil)
    }
}
