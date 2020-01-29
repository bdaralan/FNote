//
//  NoteCardCollectionCollectionViewModel.swift
//  FNote
//
//  Created by Dara Beng on 1/24/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class NoteCardCollectionCollectionViewModel: NSObject, CollectionViewCompositionalDataSource {
    
    typealias DataSourceSection = Int
    typealias DataSourceItem = NoteCardCollection
    
    
    // MARK: Property
    
    var dataSource: UICollectionViewDiffableDataSource<Int, NoteCardCollection>!
    
    var collections: [NoteCardCollection] = []
    
    var selectedCollectionIDs: Set<String> = []
    
    var contextMenus: [NoteCardCollectionCell.ContextMenu] = []
    
    
    // MARK: Action
    
    var onCollectionSelected: ((NoteCardCollection) -> Void)?
    var onContextMenuSelected: ((NoteCardCollectionCell.ContextMenu, NoteCardCollection) -> Void)?
    
    
    // MARK: Reference
    
    private weak var collectionView: UICollectionView?
    
    
    // MARK: Method
    
    func clearCellIconImages() {
        guard let collectionView = collectionView else { return }
        let visibleCells = collectionView.visibleCells as! [NoteCardCollectionCell]
        visibleCells.forEach({ $0.setIconImage(systemName: nil) })
    }
}


// MARK: - Collection Delegate

extension NoteCardCollectionCollectionViewModel: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collection = dataSource.itemIdentifier(for: indexPath) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? NoteCardCollectionCell else { return }
        onCollectionSelected?(collection)
        
        let isCollectionSelected = self.selectedCollectionIDs.contains(collection.uuid)
        let icon = isCollectionSelected ? "checkmark" : nil
        cell.setIconImage(systemName: icon)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard !contextMenus.isEmpty else { return nil }
        guard let collection = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return createContextMenuConfiguration(for: collection)
    }
}


// MARK: - Context Menu

extension NoteCardCollectionCollectionViewModel {
    
    private func createContextMenuConfiguration(for collection: NoteCardCollection) -> UIContextMenuConfiguration? {
        let actions = contextMenus.map({ createContextMenuAction(for: $0, with: collection) })
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { someElement in
            UIMenu(title: "", options: .displayInline, children: actions)
        }
        return configuration
    }

    private func createContextMenuAction(for menu: NoteCardCollectionCell.ContextMenu, with collection: NoteCardCollection) -> UIAction {
        let attribute: UIMenuElement.Attributes = menu == .delete ? .destructive : .init()
        let action = UIAction(title: menu.title, image: menu.image, attributes: attribute) { action in
            self.onContextMenuSelected?(menu, collection)
        }
        return action
    }
}


// MARK: - Collection Wrapper

extension NoteCardCollectionCollectionViewModel: CollectionViewWrapperViewModel {
    
    func setupCollectionView(_ collectionView: UICollectionView) {
        setupDataSource(with: collectionView)
        updateSnapshot(animated: false)
    }
}


// MARK: - Collection Diff Data Source

extension NoteCardCollectionCollectionViewModel {
    
    func updateSnapshot(animated: Bool, completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(collections)
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
    }
    
    func setupDataSource(with collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.registerCell(NoteCardCollectionCell.self)
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        
        dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, collection in
            let cell = collectionView.dequeueCell(NoteCardCollectionCell.self, for: indexPath)
            cell.reload(with: collection)
            
            let isCollectionSelected = self.selectedCollectionIDs.contains(collection.uuid)
            let icon = isCollectionSelected ? "checkmark" : nil
            cell.setIconImage(systemName: icon)
            
            return cell
        })
    }
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { section, environment -> NSCollectionLayoutSection? in
            self.createLayoutSection()
        }
        return layout
    }
    
    func createLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(85))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
}
