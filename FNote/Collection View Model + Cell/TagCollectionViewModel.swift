//
//  TagCollectionViewModel.swift
//  FNote
//
//  Created by Dara Beng on 1/26/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class TagCollectionViewModel: NSObject, CollectionViewCompositionalDataSource {
    
    typealias DataSourceSection = Int
    typealias DataSourceItem = Tag
    
    
    // MARK: Property
    
    var dataSource: DiffableDataSource!
    
    var tags: [Tag] = []
    
    var borderedTagIDs: Set<String> = []
    
    var contextMenus: [TagCell.ContextMenu] = []
 
    
    // MARK: Action
    
    var onTagSelected: ((Tag) -> Void)?
    var onContextMenuSelected: ((TagCell.ContextMenu, Tag) -> Void)?
    
    
    // MARK: Reference
    
    private weak var collectionView: UICollectionView?
    
    
    // MARK: Method
    
    private func setupTagCell(_ cell: TagCell, for tag: Tag) {
        cell.reload(with: tag)
        cell.showCellBorder(borderedTagIDs.contains(tag.uuid))
    }
}


// MARK: - Delegate

extension TagCollectionViewModel: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tag = dataSource.itemIdentifier(for: indexPath) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? TagCell else { return }
        onTagSelected?(tag)
        cell.showCellBorder(borderedTagIDs.contains(tag.uuid))
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard !contextMenus.isEmpty else { return nil }
        guard let tag = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return createContextMenuConfiguration(for: tag)
    }
}


// MARK: - Context Menu

extension TagCollectionViewModel {
    
    private func createContextMenuConfiguration(for tag: Tag) -> UIContextMenuConfiguration? {
        let actions = contextMenus.map({ createContextMenuAction(for: $0, with: tag) })
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { someElement in
            UIMenu(title: "", options: .displayInline, children: actions)
        }
        return configuration
    }

    private func createContextMenuAction(for menu: TagCell.ContextMenu, with tag: Tag) -> UIAction {
        let attribute: UIMenuElement.Attributes = menu == .delete ? .destructive : .init()
        let action = UIAction(title: menu.title, image: menu.image, attributes: attribute) { action in
            self.onContextMenuSelected?(menu, tag)
        }
        return action
    }
}



// MARK: - Collection Wrapper

extension TagCollectionViewModel: CollectionViewWrapperViewModel {
    
    func setupCollectionView(_ collectionView: UICollectionView) {
        setupDataSource(with: collectionView)
        updateSnapshot(animated: false)
    }
}


// MARK: - Data Source

extension TagCollectionViewModel {
    
    func setupDataSource(with collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.delegate = self
        collectionView.registerCell(TagCell.self)
        collectionView.registerHeader(LabelCollectionHeader.self)
        collectionView.alwaysBounceVertical = true
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, tag in
            let cell = collectionView.dequeueCell(TagCell.self, for: indexPath)
            self.setupTagCell(cell, for: tag)
            return cell
        }
    }
    
    func updateSnapshot(animated: Bool, completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(tags)
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
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

        let groupHeight = NSCollectionLayoutDimension.absolute(44 + 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: groupHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
}
