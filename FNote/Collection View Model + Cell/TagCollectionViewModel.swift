//
//  TagCollectionViewModel.swift
//  FNote
//
//  Created by Dara Beng on 1/26/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class TagCollectionViewModel: NSObject, CollectionViewCompositionalDataSource {
    
    typealias DataSourceSection = Section
    typealias DataSourceItem = Tag
    
    enum Section {
        case available
        case selected
        case unselected
    }
    
    
    // MARK: Property
    
    var dataSource: DiffableDataSource!
    
    var sections: [Section] = []
    
    var availableTags: [Tag] = []
    
    var selectedTags: [Tag] = []
    var unselectedTags: [Tag] = []
    
    var contextMenus: [TagCell.ContextMenu] = []
 
    
    // MARK: Action
    
    var onTagSelected: ((Tag) -> Void)?
    var onContextMenuSelected: ((TagCell.ContextMenu, Tag) -> Void)?
    
    
    // MARK: Reference
    
    private weak var collectionView: UICollectionView?
}


// MARK: - Delegate

extension TagCollectionViewModel: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tag = dataSource.itemIdentifier(for: indexPath) else { return }
        onTagSelected?(tag)
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
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, tag in
            let cell = collectionView.dequeueCell(TagCell.self, for: indexPath)
            cell.reload(with: tag)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let header = collectionView.dequeueHeader(LabelCollectionHeader.self, for: indexPath)
            
            switch self.sections[indexPath.section] {
            case .available:
                header.label.text = ""
            case .selected:
                header.label.text = "SELECTED"
            case .unselected:
                header.label.text = "UNSELECTED"
            }
            
            return header
        }
    }
    
    func updateSnapshot(animated: Bool, completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        
        for section in sections {
            switch section {
            case .available: snapshot.appendItems(availableTags, toSection: section)
            case .selected: snapshot.appendItems(selectedTags, toSection: section)
            case .unselected: snapshot.appendItems(unselectedTags, toSection: section)
            }
        }
        
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
        
        if sections.elementsEqual([.selected, .unselected]) {
            section.boundarySupplementaryItems = [createHeaderSupplementaryItem()]
        }
        
        return section
    }
    
    func createHeaderSupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let kind = UICollectionView.elementKindSectionHeader
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(21))
        let item = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: kind, alignment: .top)
        return item
    }
}
