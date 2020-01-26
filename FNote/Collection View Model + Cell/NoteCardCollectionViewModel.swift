//
//  NoteCardCollectionViewModel.swift
//  FNote
//
//  Created by Dara Beng on 1/19/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class NoteCardCollectionViewModel: NSObject, CollectionViewCompositionalDataSource, CollectionViewCompositionalViewModel {
    
    typealias DataSourceSection = Int
    
    typealias DataSourceItem = NoteCard
    
    
    // MARK: Property
    
    var noteCards: [NoteCard] = []
    
    var dataSource: DiffableDataSource!
    
    var cellStyle: NoteCardCell.Style = .regular
    
    var borderedNoteCardIDs: Set<String> = []
    var disableNoteCardIDs: Set<String> = []
    var contextMenus: [NoteCardCell.ContextMenu] = []
    
    
    // MARK: Action
    
    var onNoteCardSelected: ((NoteCard) -> Void)?
    var onNoteCardQuickButtonTapped: ((NoteCardCell.QuickButtonType, NoteCard) -> Void)?
    var onContextMenuSelected: ((NoteCardCell.ContextMenu, NoteCard) -> Void)?
    
    
    // MARK: Search
    var onSearchTextDebounced: ((String) -> Void)?
    var onSearchCancel: (() -> Void)?
    
    
    // MARK: Reference
    
    private weak var collectionView: UICollectionView?
    
    private let cellID = NoteCardCell.reuseID
    private let searchFieldHeaderID = "SearchHeaderID"
}


// MARK: - Collection Delegate

extension NoteCardCollectionViewModel: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let noteCard = dataSource.itemIdentifier(for: indexPath) else { return }
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


// MARk: - Context Menu

extension NoteCardCollectionViewModel {
    
    private func createContextMenuConfiguration(for noteCard: NoteCard) -> UIContextMenuConfiguration? {
        let actions = contextMenus.map({ createContextMenuAction(for: $0, with: noteCard) })
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { someElement in
            UIMenu(title: "", options: .displayInline, children: actions)
        }
        return configuration
    }
    
    private func createContextMenuAction(for menu: NoteCardCell.ContextMenu, with noteCard: NoteCard) -> UIAction {
        let attribute: UIMenuElement.Attributes = menu == .delete ? .destructive : .init()
        let action = UIAction(title: menu.title, image: menu.image, attributes: attribute) { action in
            self.onContextMenuSelected?(menu, noteCard)
        }
        return action
    }
}


// MARK: - Collection Diff Data Source

extension NoteCardCollectionViewModel {
    
    func updateSnapshot(animated: Bool, completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(noteCards, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
    }
    
    func setupCollectionView(_ collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.register(NoteCardCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.register(SearchFieldCellHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: searchFieldHeaderID)
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        // MARK: Cell
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, noteCard in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! NoteCardCell
            cell.reload(with: noteCard)
            cell.setCellStyle(self.cellStyle)
            cell.showCellBorder(self.borderedNoteCardIDs.contains(noteCard.uuid))
            cell.disableCell(self.disableNoteCardIDs.contains(noteCard.uuid))
            cell.onQuickButtonTapped = self.onNoteCardQuickButtonTapped
            return cell
        }
        
        // MARK: Header
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.searchFieldHeaderID, for: indexPath) as! SearchFieldCellHeader
            
            header.onSearchTextDebounced = { [weak self] searchText in
                self?.onSearchTextDebounced?(searchText)
            }
            
            header.onCancel = { [weak self] in
                self?.onSearchCancel?()
                header.searchText = ""
                header.searchField.resignFirstResponder()
                header.showCancel(false, animated: true)
            }
            
            return header
        }
    }
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { section, environment in
            self.createLayoutSection()
        }
        return layout
    }
    
    func createLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let height = cellStyle.height
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        section.boundarySupplementaryItems = [createSearchFieldSupplementaryItem()]
//        if onSearchTextDebounced != nil {
//            section.boundarySupplementaryItems = [createSearchFieldSupplementaryItem()]
//        }
        
        return section
    }
    
    func createSearchFieldSupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(35 + 16))
        let item = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        return item
    }
}
