//
//  PublicCollectionViewModel.swift
//  FNote
//
//  Created by Dara Beng on 2/27/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class PublicCollectionViewModel: NSObject, CollectionViewCompositionalDataSource {
    
    typealias DataSourceSection = PublicSection
    typealias DataSourceItem = PublicSectionItem
    
    var dataSource: DiffableDataSource!
    
    var sections: [PublicSection] = []
    
    var isHorizontallyCompact = true
    
    var onSectionScrolled: ((PublicSectionType, CGPoint) -> Void)?
}


extension PublicCollectionViewModel {

    func updateSection(with section: PublicSection) {
        if let index = sections.firstIndex(where: { $0.type == section.type }) {
            sections[index] = section
        } else {
            sections.append(section)
        }
        sections.sort(by: { $0.type.displayOrder < $1.type.displayOrder })
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
            case .randomCollection, .recentCollection:
                let cell = collectionView.dequeueCell(PublicCollectionCell.self, for: indexPath)
                let collection = item.object as! PublicCollection
                cell.reload(with: collection)
                self.reloadUsername(for: cell, userID: collection.authorID)
                return cell
                
            case .recentCard:
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
    
    private func handleLayoutSectionScrolled(sectionType: PublicSectionType, offset: CGPoint) {
        onSectionScrolled?(sectionType, offset)
    }
}


// MARK: - Create Layout

extension PublicCollectionViewModel {
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { section, environment in
            let sectionType = self.sections[section].type
            let layoutSection: NSCollectionLayoutSection
            
            switch sectionType {
            case .randomCollection: layoutSection = self.createRandomCollectionLayoutSection()
            case .recentCollection: layoutSection = self.createRecentCollectionLayoutSection()
            case .recentCard: layoutSection = self.createRecentCardLayoutSection()
            }
            
            layoutSection.visibleItemsInvalidationHandler = { visibleItems, offset, environment in
                self.handleLayoutSectionScrolled(sectionType: sectionType, offset: offset)
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
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 12, leading: 16, bottom: 0, trailing: 16)
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
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
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


// MARK: - Delegate

extension PublicCollectionViewModel: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch sections[indexPath.section].type {
        case .randomCollection, .recentCollection:
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
        
        case .recentCard: break
        }
    }
}


// MARK: - Fetch Method

extension PublicCollectionViewModel {
    
    func fetchRecentCollections(completedWithError: ((Error?) -> Void)?) {
        PublicRecordManager.shared.queryRecentCollections { result in
            switch result {
            case .success(let records):
                let collections = records.map({ PublicCollection(record: $0) })
                let collectionItems = collections.map({ PublicSectionItem(object: $0) })
                
                let section = PublicSection(type: .recentCollection, title: "Recent Collection", items: collectionItems)
                self.updateSection(with: section)
                DispatchQueue.main.async {
                    self.updateSnapshot(animated: false, completion: nil)
                    completedWithError?(nil)
                }
            
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    completedWithError?(error)
                }
            }
        }
    }
    
    func fetchRecentNoteCards(completedWithError: ((Error?) -> Void)?) {
        PublicRecordManager.shared.queryRecentCards { result in
            switch result {
            case .success(let records):
                let cards = records.map({ PublicNoteCard(record: $0) })
                let cardItems = cards.map({ PublicSectionItem(object: $0) })
                
                let section = PublicSection(type: .recentCard, title: "Recent Note Cards", items: cardItems)
                self.updateSection(with: section)
                DispatchQueue.main.async {
                    self.updateSnapshot(animated: false, completion: nil)
                    completedWithError?(nil)
                }
            
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    completedWithError?(error)
                }
            }
        }
    }
}


// MARK: - Section

struct PublicSection: Hashable {
    
    let type: PublicSectionType
    
    let title: String
    
    var items: [PublicSectionItem]
}


// MARK: - Section Item

struct PublicSectionItem: Hashable {
    
    let object: CloudKitRecord
    
    static func == (lhs: PublicSectionItem, rhs: PublicSectionItem) -> Bool {
        lhs.object.recordName == rhs.object.recordName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(object.recordName)
    }
}


// MARK: - Section Type

enum PublicSectionType {
    case recentCollection
    case randomCollection
    case recentCard
    
    var displayOrder: Int {
        switch self {
        case .recentCollection: return 0
        case .randomCollection: return 1
        case .recentCard: return 2
        }
    }
}


// MARK: - Sample

extension PublicCollectionViewModel {
    
    static let sample: PublicCollectionViewModel = {
        let model = PublicCollectionViewModel()
        model.sections = [
            .init(type: .recentCollection, title: "Recent Collections", items: [
                .init(object: PublicCollection(collectionID: "01", authorID: "", name: "Korean 101", description: "Some long description text that will fill the text rectangle box.", primaryLanguage: "KOR", secondaryLanguage: "ENG", tags: ["Food", "Greeting", "Travel"], cardsCount: 49)),
                .init(object: PublicCollection(collectionID: "02", authorID: "", name: "Japanese 101", description: "Some long description text that will fill the text rectangle box.", primaryLanguage: "JPN", secondaryLanguage: "ENG", tags: ["Beginner", "Pro", "Noob"], cardsCount: 92)),
                .init(object: PublicCollection(collectionID: "03", authorID: "", name: "Korean 101", description: "Some long description text that will fill the text rectangle box.", primaryLanguage: "KOR", secondaryLanguage: "ENG", tags: ["Food", "Greeting", "Travel"], cardsCount: 49)),
                .init(object: PublicCollection(collectionID: "04", authorID: "", name: "Japanese 101", description: "Some long description text that will fill the text rectangle box.", primaryLanguage: "JPN", secondaryLanguage: "ENG", tags: ["Beginner", "Pro", "Noob"], cardsCount: 92))
            ]),
            
            .init(type: .randomCollection, title: "Random Collections", items: []),
            
            .init(type: .recentCard, title: "Random Cards", items: []),
        ]
        return model
    }()
}
