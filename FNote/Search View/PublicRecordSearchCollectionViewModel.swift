//
//  PublicRecordSearchCollectionViewModel.swift
//  FNote
//
//  Created by Dara Beng on 4/24/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class PublicRecordSearchCollectionViewModel: NSObject, ObservableObject, CollectionViewCompositionalDataSource, CollectionViewWrapperViewModel, UICollectionViewDelegate {
    
    typealias DataSourceSection = Int
    
    typealias DataSourceItem = PublicSectionItem
    
    var dataSource: DiffableDataSource!
    
    var collections: [PublicCollection] = []
    
    
    // MARK: Action
    
    var onCollectionSelected: ((PublicCollection) -> Void)?
    
    
    // MARK: Data Source & Snapshot
    
    func setupCollectionView(_ collectionView: UICollectionView) {
        setupDataSource(with: collectionView)
    }
    
    func setupDataSource(with collectionView: UICollectionView) {
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        collectionView.delegate = self
        
        collectionView.registerCell(PublicCollectionCell.self)
        
        dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            let collection = item.object as! PublicCollection
            let cell = collectionView.dequeueCell(PublicCollectionCell.self, for: indexPath)
            cell.reload(with: collection)
            if let userRecord = PublicRecordManager.shared.cachedRecord(forKey: collection.authorID) {
                let username = userRecord[PublicUser.RecordFields.username.stringValue] as? String ?? ""
                cell.setAuthor(name: username)
            }
            return cell
        })
    }
    
    func updateSnapshot(animated: Bool, completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        
        let items = collections.map({ PublicSectionItem(itemID: $0.collectionID, object: $0) })
        snapshot.appendItems(items)
        
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
    }
    
    
    // MARK: Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        onCollectionSelected?(item.object as! PublicCollection)
    }
    
    
    // MARK: Layout
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { section, environment in
            let layoutSection = self.createCollectionLayoutSection()
            return layoutSection
        }
        
//        let configuration = UICollectionViewCompositionalLayoutConfiguration()
//        configuration.interSectionSpacing = 16
//
//        layout.configuration = configuration
        
        return layout
    }
    
    private func createCollectionLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
        let groupWidth: NSCollectionLayoutDimension = .fractionalWidth(1)
        let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth, heightDimension: .estimated(175))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 32
        section.contentInsets = .init(top: 16, leading: 16, bottom: 140, trailing: 16)
//        section.boundarySupplementaryItems = [createSectionHeaderSupplementaryItem(height: 40)]
        
        return section
    }
    
    private func createSectionHeaderSupplementaryItem(height: CGFloat) -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height))
        let headerKind = UICollectionView.elementKindSectionHeader
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: headerKind, alignment: .topLeading)
        return header
    }
}
