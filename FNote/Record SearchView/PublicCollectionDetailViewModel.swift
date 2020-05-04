//
//  PublicCollectionDetailViewModel.swift
//  FNote
//
//  Created by Dara Beng on 5/2/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class PublicCollectionDetailViewModel: CollectionViewCompositionalDataSource, CollectionViewWrapperViewModel {
    
    typealias DataSourceSection = Int
    typealias DataSourceItem = PublicNoteCard
    
    var dataSource: DiffableDataSource!
    
    var cards: [PublicNoteCard] = []
    
    let cellStyle: NoteCardCell.Style = .short
    
    var contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
}


extension PublicCollectionDetailViewModel {
    
    func setupCollectionView(_ collectionView: UICollectionView) {
        setupDataSource(with: collectionView)
        updateSnapshot(animated: false)
    }
    
    func updateSnapshot(animated: Bool, completion: (() -> Void)? = nil) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(cards)
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
    }
    
    func setupDataSource(with collectionView: UICollectionView) {
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.registerCell(NoteCardCell.self)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        // MARK: Cell
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, card in
            let cell = collectionView.dequeueCell(NoteCardCell.self, for: indexPath)
            cell.reload(with: card)
            cell.setCellStyle(self.cellStyle)
            return cell
        }
    }
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { section, environment in
            return self.createNoteCardLayoutSection()
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
        section.contentInsets = contentInsets
        
        return section
    }
}
