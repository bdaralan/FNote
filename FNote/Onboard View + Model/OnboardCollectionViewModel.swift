//
//  OnboardCollectionViewModel.swift
//  FNote
//
//  Created by Dara Beng on 2/13/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


// MARK: - Onboard View Model

class OnboardCollectionViewModel: NSObject, CollectionViewCompositionalDataSource {
    
    typealias DataSourceSection = Int
    typealias DataSourceItem = OnboardPage
    
    let pages = OnboardPage.load()
    
    var dataSource: DiffableDataSource!
    
    var onPageChanged: ((Int, OnboardPage) -> Void)?
    
    var iPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}


extension OnboardCollectionViewModel: CollectionViewWrapperViewModel {
    
    func setupCollectionView(_ collectionView: UICollectionView) {
        setupDataSource(with: collectionView)
        updateSnapshot(animated: false, completion: nil)
    }
}


extension OnboardCollectionViewModel {
    
    func setupDataSource(with collectionView: UICollectionView) {
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.registerCell(OnboardCell.self)
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueCell(OnboardCell.self, for: indexPath)
            cell.reload(with: item)
            return cell
        }
    }
    
    func updateSnapshot(animated: Bool, completion: (() -> Void)?) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(pages)
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        section.visibleItemsInvalidationHandler = { visibleLayoutItems, offset, layoutEnvironment in
            let containerWidth = layoutEnvironment.container.contentSize.width
            guard offset.x.truncatingRemainder(dividingBy: containerWidth) == 0 else { return }
            let pageIndex = Int(offset.x / containerWidth)
            self.onPageChanged?(pageIndex, self.pages[pageIndex])
        }
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}



