//
//  CommunityViewModel.swift
//  FNote
//
//  Created by Dara Beng on 2/27/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class CommunityViewModel: NSObject, CollectionViewCompositionalDataSource {
    
    typealias DataSourceSection = PublicSection
    typealias DataSourceItem = PublicSectionItem
    
    var dataSource: DiffableDataSource!
    
    let sections: [DataSourceSection] = [.recentCollections, .recentCards]
    
    var recentCollectionItems: [DataSourceItem] = []
    
    var recentCardItems: [DataSourceItem] = []
    
    var isHorizontallyCompact = true
    
    var contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 32, trailing: 16)
    
    var onCollectionSelected: ((PublicCollection, DataSourceSection) -> Void)?
    
    var onCardSelected: ((PublicCard, DataSourceSection) -> Void)?
    
    var onVoteTriggered: ((PublicCollectionCell) -> Void)?
    
    private var layoutPlaceholder = false
}


// MARK: - Wrapper

extension CommunityViewModel: CollectionViewWrapperViewModel {
    
    func setupCollectionView(_ collectionView: UICollectionView) {
        setupDataSource(with: collectionView)
        updateSnapshot(animated: false, completion: nil)
    }
}


// MARK: - Data Source

extension CommunityViewModel {
    
    func setupDataSource(with collectionView: UICollectionView) {
        collectionView.collectionViewLayout = createCompositionalLayout()
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.registerCell(PublicCollectionCell.self)
        collectionView.registerCell(NoteCardCell.self)
        collectionView.registerHeader(CollectionHeaderLabel.self)
        
        isHorizontallyCompact = collectionView.traitCollection.horizontalSizeClass == .compact
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            let section = self.sections[indexPath.section]
            
            if self.layoutPlaceholder { // placeholder cell
                return self.placeholderCell(for: section, at: indexPath, collectionView: collectionView)
            }
            
            switch section {
            case .recentCollections:
                let cell = collectionView.dequeueCell(PublicCollectionCell.self, for: indexPath)
                let collection = item.object as! PublicCollection
                cell.reload(with: collection)
                cell.onVoteTriggered = self.onVoteTriggered
                return cell
                
            case .recentCards:
                let cell = collectionView.dequeueCell(NoteCardCell.self, for: indexPath)
                let publishCard = item.object as! PublicCard
                cell.reload(with: publishCard)
                cell.setCellStyle(.short)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let header = collectionView.dequeueHeader(CollectionHeaderLabel.self, for: indexPath)
            switch self.sections[indexPath.section] {
            case .recentCollections: header.label.text = "RECENT COLLECTIONS"
            case .recentCards: header.label.text = "RECENT CARDS"
            }
            header.setLabelPosition(.bottom)
            return header
        }
    }
    
    func updateSnapshot(animated: Bool, completion: (() -> Void)?) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        for section in sections {
            switch section {
            case .recentCollections:
                snapshot.appendItems(recentCollectionItems, toSection: section)
            case .recentCards:
                snapshot.appendItems(recentCardItems, toSection: section)
            }
        }
        
        layoutPlaceholder = false
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
    }
}


// MARK: - Create Layout

extension CommunityViewModel {
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { section, environment in
            let layoutSection: NSCollectionLayoutSection
            let section = self.sections[section]
            let insets = self.contentInsets
            
            switch section {
            case .recentCollections: layoutSection = self.createRecentCollectionLayoutSection()
            case .recentCards: layoutSection = self.createRecentCardLayoutSection()
            }
            
            // set last section content insets
            if section == self.sections.last {
                layoutSection.contentInsets = insets
            } else {
                layoutSection.contentInsets.top = insets.top
                layoutSection.contentInsets.bottom = 0
                layoutSection.contentInsets.leading = insets.leading
                layoutSection.contentInsets.trailing = insets.trailing
            }
            
            return layoutSection
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 16
        
        layout.configuration = configuration
        
        return layout
    }
    
    private func createRandomCollectionLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupWidth: NSCollectionLayoutDimension = isHorizontallyCompact ? .fractionalWidth(0.8) : .absolute(300)
        let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth, heightDimension: .estimated(175))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 16
        section.boundarySupplementaryItems = [createSectionHeaderSupplementaryItem(height: 40)]
        
        return section
    }
    
    private func createRecentCollectionLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
        let groupWidth: NSCollectionLayoutDimension = isHorizontallyCompact ? .fractionalWidth(0.8) : .absolute(300)
        let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth, heightDimension: .estimated(175))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.boundarySupplementaryItems = [createSectionHeaderSupplementaryItem(height: 40)]
        
        return section
    }
    
    private func createRecentCardLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupWidth: NSCollectionLayoutDimension = isHorizontallyCompact ? .fractionalWidth(0.8) : .absolute(300)
        let groupHeight = NoteCardCell.Style.short.height
        let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth, heightDimension: .absolute(groupHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 16
        section.boundarySupplementaryItems = [createSectionHeaderSupplementaryItem(height: 40)]
        
        return section
    }
    
    private func createSectionHeaderSupplementaryItem(height: CGFloat) -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height))
        let headerKind = UICollectionView.elementKindSectionHeader
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: headerKind, alignment: .topLeading)
        return header
    }
}


// MARK: - Delegate

extension CommunityViewModel: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let section = sections[indexPath.section]
        switch section {
        case .recentCollections:
            guard let collection = item.object as? PublicCollection else { return }
            onCollectionSelected?(collection, section)
        case .recentCards:
            guard let card = item.object as? PublicCard else { return }
            onCardSelected?(card, section)
        }
    }
}


// MARK: - Fetch Method

extension CommunityViewModel {
    
    func fetchData(completedWithError: ((Error?) -> Void)?) {
        fetchRecentCollections { error in
            guard error == nil else {
                completedWithError?(error)
                return
            }
            
            self.fetchRecentNoteCards { error in
                guard error == nil else {
                    completedWithError?(error)
                    return
                }
                
                completedWithError?(nil)
            }
        }
    }
    
    /// Fetch recent collections and update snapshot.
    ///
    /// This also fetches user record and update the snapshot for collection's author name.
    func fetchRecentCollections(completedWithError: ((Error?) -> Void)?) {
        let recordManager = PublicRecordManager.shared
        recordManager.queryRecentCollections { result in
            switch result {
            case let .success(records):
                let items = records.map { record -> DataSourceItem in
                    let collection = PublicCollection(record: record)
                    return DataSourceItem(itemID: collection.collectionID, object: collection)
                }
                self.recentCollectionItems = items
                completedWithError?(nil)
            
            case let .failure(error):
                completedWithError?(error)
                print(error)
            }
        }
    }
    
    func fetchRecentNoteCards(completedWithError: ((Error?) -> Void)?) {
        PublicRecordManager.shared.queryRecentCards { result in
            switch result {
            case let .success(records):
                let items = records.map { record -> DataSourceItem in
                    let card = PublicCard(record: record)
                    return DataSourceItem(itemID: card.cardID, object: card)
                }
                self.recentCardItems = items
                completedWithError?(nil)

            case let .failure(error):
                completedWithError?(error)
                print(error)
            }
        }
    }
}


// MARK: - Section

enum PublicSection {
    case recentCollections
    case recentCards
}


// MARK: - Section Item

struct PublicSectionItem: Hashable {
    
    /// The item ID.
    let itemID: String
    
    /// The item's object.
    let object: Any?
    
    static func == (lhs: PublicSectionItem, rhs: PublicSectionItem) -> Bool {
        lhs.itemID == rhs.itemID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(itemID)
    }
}


// MARK: - Placeholder

extension CommunityViewModel {
    
    func setPlaceholderItems() {
        layoutPlaceholder = true
        
        recentCollectionItems = (1...9).map { _ in
            DataSourceItem(itemID: UUID().uuidString, object: nil)
        }
        
        recentCardItems = (1...9).map { _ in
            DataSourceItem(itemID: UUID().uuidString, object: nil)
        }
    }
    
    func placeholderCell(for section: DataSourceSection, at indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        switch section {
        case .recentCollections:
            let cell = collectionView.dequeueCell(PublicCollectionCell.self, for: indexPath)
            cell.placeholder()
            return cell
        case .recentCards:
            let cell = collectionView.dequeueCell(NoteCardCell.self, for: indexPath)
            cell.placeholder()
            return cell
        }
    }
}
