//
//  PublicCollectionViewModel.swift
//  FNote
//
//  Created by Dara Beng on 2/27/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class PublicCollectionViewModel: NSObject, CollectionViewCompositionalDataSource {
    
    typealias DataSourceSection = PublishSection
    typealias DataSourceItem = PublishSectionItem
    
    var dataSource: DiffableDataSource!
    
    var sections: [PublishSection] = []
    
    var isHorizontallyCompact = true
}


extension PublicCollectionViewModel {

    func updateSection(type: PublishSectionType, with section: PublishSection) {
        if let index = sections.firstIndex(where: { $0.type == type }) {
            sections[index] = section
        } else {
            sections.append(section)
        }
    }
}


// MARK: - Wrapper

extension PublicCollectionViewModel: CollectionViewWrapperViewModel {
    
    func setupCollectionView(_ collectionView: UICollectionView) {
        setupDataSource(with: collectionView)
        updateSnapshot(animated: false, completion: nil)
    }
}


// MARK: - Data Source

extension PublicCollectionViewModel {
    
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
            switch self.sections[indexPath.section].type {
            case .featuredCollection, .recentCollection:
                let cell = collectionView.dequeueCell(PublicCollectionCell.self, for: indexPath)
                let collection = item.object as! PublicCollection
                cell.reload(with: collection)
                self.reloadUsername(for: cell, userID: collection.authorID)
                return cell
                
            case .randomCard:
                let cell = collectionView.dequeueCell(NoteCardCell.self, for: indexPath)
                let publishCard = item.object as! PublicNoteCard
                cell.reload(with: publishCard)
                cell.setCellStyle(.short)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let header = collectionView.dequeueHeader(CollectionHeaderLabel.self, for: indexPath)
            header.label.text = self.sections[indexPath.section].title.uppercased()
            header.setLabelPosition(.bottom)
            return header
        }
    }
    
    func reloadUsername(for cell: PublicCollectionCell, userID: String) {
        guard !userID.isEmpty else { return }
        
        let recordManager = PublicRecordManager.shared
        let usernameKey = PublicUser.RecordKeys.username.stringValue
        
        // check cache
        if let userRecord = recordManager.cachedRecord(forKey: userID) {
            cell.setAuthor(name: userRecord[usernameKey] as! String)
            return
        }
        
        // query user record and don't care about error
        recordManager.queryUsers(withIDs: [userID]) { result in
            guard case .success(let records) = result, let record = records.first else { return }
            
            // cache queried record
            recordManager.cacheRecords(records, usingKey: PublicUser.RecordKeys.userID)
            
            // update cell if still valid
            guard cell.object?.authorID == userID else { return }
            guard let username = record[usernameKey] as? String else { return }
            DispatchQueue.main.async {
                cell.setAuthor(name: username)
            }
        }
    }
    
    func updateSnapshot(animated: Bool, completion: (() -> Void)?) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        
        for section in sections {
            snapshot.appendItems(section.items, toSection: section)
        }
        
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { section, environment in
            switch self.sections[section].type {
            case .featuredCollection: return self.createFeaturedCollectionLayoutSection()
            case .recentCollection: return self.createRecentCollectionLayoutSection()
            case .randomCard: return self.createRandomCardLayoutSection()
            }
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 16
        
        layout.configuration = configuration
        
        return layout
    }
    
    private func createFeaturedCollectionLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupWidth: NSCollectionLayoutDimension = isHorizontallyCompact ? .fractionalWidth(0.8) : .absolute(300)
        let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth, heightDimension: .estimated(175))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 12, leading: 16, bottom: 0, trailing: 16)
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
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 12, leading: 16, bottom: 0, trailing: 16)
        section.boundarySupplementaryItems = [createSectionHeaderSupplementaryItem(height: 40)]
        
        return section
    }
    
    private func createRandomCardLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupWidth: NSCollectionLayoutDimension = isHorizontallyCompact ? .fractionalWidth(0.8) : .absolute(300)
        let groupHeight = NoteCardCell.Style.short.height
        let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth, heightDimension: .absolute(groupHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 12, leading: 16, bottom: 32, trailing: 16)
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


extension PublicCollectionViewModel: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch sections[indexPath.section].type {
        case .featuredCollection, .recentCollection:
            guard let collection = dataSource.itemIdentifier(for: indexPath)?.object as? PublicCollection else { return }
            print(collection.cardsCount)
            
            let recordManager = PublicRecordManager.shared
            recordManager.queryCards(withCollectionID: collection.collectionID) { result in
                switch result {
                case .success((let records)):
                    records.forEach({ print($0.keyedRecord(keys: PublicNoteCard.RecordKeys.self)[.translation] as Any) })
                default:
                    print("failed to download cards")
                }
            }
        
        case .randomCard: break
        }
    }
}


// MARK: - Section

struct PublishSection: Hashable {
    
    let type: PublishSectionType
    
    let title: String
    
    var items: [PublishSectionItem]
}


// MARK: - Section Item

struct PublishSectionItem: Hashable {
    
    let object: CloudKitRecord
    
    static func == (lhs: PublishSectionItem, rhs: PublishSectionItem) -> Bool {
        lhs.object.recordName == rhs.object.recordName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(object.recordName)
    }
}


// MARK: - Section Type

enum PublishSectionType {
    case featuredCollection
    case recentCollection
    case randomCard
}


// MARK: - Sample

extension PublicCollectionViewModel {
    
    static let sample: PublicCollectionViewModel = {
        let model = PublicCollectionViewModel()
        model.sections = [
//            .init(type: .featuredCollection, title: "Featured Collections", items: [
//                .init(object: PublicCollection(collectionID: "01", authorID: "", name: "Korean 101", description: "Some long description text that will fill the text rectangle box.", primaryLanguage: "KOR", secondaryLanguage: "ENG", tags: ["Food", "Greeting", "Travel"], cardsCount: 49)),
//                .init(object: PublicCollection(collectionID: "02", authorID: "", name: "Japanese 101", description: "Some long description text that will fill the text rectangle box.", primaryLanguage: "JPN", secondaryLanguage: "ENG", tags: ["Beginner", "Pro", "Noob"], cardsCount: 92)),
//                .init(object: PublicCollection(collectionID: "03", authorID: "", name: "Korean 101", description: "Some long description text that will fill the text rectangle box.", primaryLanguage: "KOR", secondaryLanguage: "ENG", tags: ["Food", "Greeting", "Travel"], cardsCount: 49)),
//                .init(object: PublicCollection(collectionID: "04", authorID: "", name: "Japanese 101", description: "Some long description text that will fill the text rectangle box.", primaryLanguage: "JPN", secondaryLanguage: "ENG", tags: ["Beginner", "Pro", "Noob"], cardsCount: 92))
//            ]),
            
            .init(type: .recentCollection, title: "Recent Collections", items: []),
            
            .init(type: .randomCard, title: "Random Cards", items: []),
        ]
        return model
    }()
}
