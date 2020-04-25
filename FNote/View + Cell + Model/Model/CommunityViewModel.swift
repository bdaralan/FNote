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
    
    var sections: [PublicSection] = []
    
    var isHorizontallyCompact = true
    
    var lastSectionContentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 32, trailing: 16)
    
    var onItemSelected: ((PublicSectionItem, PublicSectionType) -> Void)?
}


extension CommunityViewModel {

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
        collectionView.registerCell(ActionCollectionViewCell.self)
        collectionView.registerCell(PublicCollectionCell.self)
        collectionView.registerCell(NoteCardCell.self)
        collectionView.registerHeader(CollectionHeaderLabel.self)
        
        isHorizontallyCompact = collectionView.traitCollection.horizontalSizeClass == .compact
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            let sectionType = self.sections[indexPath.section].type
            switch sectionType {
            case .action:
                let cell = collectionView.dequeueCell(ActionCollectionViewCell.self, for: indexPath)
                let action = item.object as! PublicSectionAction
                cell.setAction(title: action.title, description: action.description)
                return cell
                
            case .randomCollection, .recentCollection:
                let cell = collectionView.dequeueCell(PublicCollectionCell.self, for: indexPath)
                let collection = item.object as! PublicCollection
                cell.reload(with: collection)
                self.setCollectionCellAuthorName(cell, userID: collection.authorID)
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
    
    /// Grab author's name from record manager's cached record and set the value.
    func setCollectionCellAuthorName(_ cell: PublicCollectionCell, userID: String) {
        guard !userID.isEmpty else { return }
        guard let record = PublicRecordManager.shared.cachedRecord(forKey: userID) else { return }
        let user = PublicUser(record: record)
        cell.setAuthor(name: user.username)
    }
    
    func updateSnapshot(animated: Bool, completion: (() -> Void)?) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        for section in sections {
            snapshot.appendItems(section.items, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
    }
}


// MARK: - Create Layout

extension CommunityViewModel {
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { section, environment in
            let sectionType = self.sections[section].type
            let layoutSection: NSCollectionLayoutSection
            
            switch sectionType {
            case .action: layoutSection = self.createActionLayoutSection()
            case .randomCollection: layoutSection = self.createRandomCollectionLayoutSection()
            case .recentCollection: layoutSection = self.createRecentCollectionLayoutSection()
            case .recentCard: layoutSection = self.createRecentCardLayoutSection()
            }
            
            // set last section content insets
            if section == self.sections.count - 1 {
                layoutSection.contentInsets.bottom = 140
            }
            
            return layoutSection
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 16
        
        layout.configuration = configuration
        
        return layout
    }
    
    private func createActionLayoutSection() -> NSCollectionLayoutSection {
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.custom(layoutSize: groupSize) { layoutEnvironment in
            let collectionWidth = layoutEnvironment.container.contentSize.width
            let itemHeight = CGFloat(60)

            let publishItemFrame = CGRect(x: 0, y: 0, width: collectionWidth * 0.8, height: itemHeight)
            let publishItem = NSCollectionLayoutGroupCustomItem(frame: publishItemFrame)

            let refreshItemFrame = CGRect(x: publishItemFrame.width + 16, y: 0, width: 120, height: itemHeight)
            let refreshItem = NSCollectionLayoutGroupCustomItem(frame: refreshItemFrame)

            return [publishItem, refreshItem]
        }
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 12, leading: 16, bottom: 0, trailing: 120 + 16)
        
        return section
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
        section.contentInsets = lastSectionContentInsets
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
        let sectionType = sections[indexPath.section].type
        switch sectionType {
        case .action:
            onItemSelected?(item, sectionType)
        case .randomCollection, .recentCollection, .recentCard:
            onItemSelected?(item, sectionType)
        }
    }
}


// MARK: - Fetch Method

extension CommunityViewModel {
    
    func fetchData(completedWithError: ((Error?) -> Void)?) {
        let updateSnapshot: ((Error?) -> Void) = { error in
            DispatchQueue.main.async {
                self.updateSnapshot(animated: false) {
                    completedWithError?(error)
                }
            }
        }
        
        fetchRecentCollections { error in
            guard error == nil else {
                updateSnapshot(error)
                return
            }
            
            self.fetchRecentNoteCards { error in
                guard error == nil else {
                    updateSnapshot(error)
                    return
                }
                
                updateSnapshot(error)
                
                let recordManager = PublicRecordManager.shared
                let collectionSection = self.sections.first(where: { $0.type == .recentCollection })
                let userIDs = collectionSection?.items.compactMap { item -> String? in
                    let collection = item.object as? PublicCollection
                    return collection?.authorID
                }
                
                recordManager.queryUsers(withIDs: userIDs ?? []) { result in
                    switch result {
                    case .success(let userRecords):
                        recordManager.cacheRecords(userRecords, usingRecordField: PublicUser.RecordFields.userID)
                        updateSnapshot(error)
                    case .failure(let error):
                        updateSnapshot(error)
                    }
                }
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
            case .success(let records):
                let collections = records.map({ PublicCollection(record: $0) })
                let collectionItems = collections.map({ PublicSectionItem(itemID: $0.recordName, object: $0) })
                let section = PublicSection(type: .recentCollection, title: "Recent Collections", items: collectionItems)
                self.updateSection(with: section)
                completedWithError?(nil)
            
            case .failure(let error):
                completedWithError?(error)
                print(error)
            }
        }
    }
    
    func fetchRecentNoteCards(completedWithError: ((Error?) -> Void)?) {
        PublicRecordManager.shared.queryRecentCards { result in
            switch result {
            case .success(let records):
                let cards = records.map({ PublicNoteCard(record: $0) })
                let cardItems = cards.map({ PublicSectionItem(itemID: $0.recordName, object: $0) })
                let section = PublicSection(type: .recentCard, title: "Recent Cards", items: cardItems)
                self.updateSection(with: section)
                completedWithError?(nil)
            
            case .failure(let error):
                completedWithError?(error)
                print(error)
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
    
    let itemID: String
    
    let object: Any?
    
    static func == (lhs: PublicSectionItem, rhs: PublicSectionItem) -> Bool {
        lhs.itemID == rhs.itemID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(itemID)
    }
}


// MARK: - Section Type

enum PublicSectionType {
    case action
    case recentCollection
    case randomCollection
    case recentCard
    
    var displayOrder: Int {
        switch self {
        case .action: return 0
        case .recentCollection: return 1
        case .randomCollection: return 2
        case .recentCard: return 3
        }
    }
}


enum PublicSectionAction: CaseIterable {
    case publishCollection
    case refreshData
    
    var title: String {
        switch self {
        case .publishCollection: return "PUBLISH COLLECTION"
        case .refreshData: return "REFRESH"
        }
    }
    
    var description: String? {
        switch self {
        case .publishCollection: return "share a copy of your collection with the world"
        default: return nil
        }
    }
}


// MARK: - Sample

extension CommunityViewModel {
    
    static let sample: CommunityViewModel = {
        let model = CommunityViewModel()
        model.sections = [
            .init(type: .recentCollection, title: "Recent Collections", items: [
                .init(itemID: "01", object: PublicCollection(collectionID: "01", authorID: "", authorName: "", name: "Korean 101", description: "Some long description text that will fill the text rectangle box.", primaryLanguage: "KOR", secondaryLanguage: "ENG", tags: ["Food", "Greeting", "Travel"], cardsCount: 49)),
                .init(itemID: "02", object: PublicCollection(collectionID: "02", authorID: "", authorName: "", name: "Japanese 101", description: "Some long description text that will fill the text rectangle box.", primaryLanguage: "JPN", secondaryLanguage: "ENG", tags: ["Beginner", "Pro", "Noob"], cardsCount: 92)),
                .init(itemID: "03", object: PublicCollection(collectionID: "03", authorID: "", authorName: "", name: "Korean 101", description: "Some long description text that will fill the text rectangle box.", primaryLanguage: "KOR", secondaryLanguage: "ENG", tags: ["Food", "Greeting", "Travel"], cardsCount: 49)),
                .init(itemID: "04", object: PublicCollection(collectionID: "04", authorID: "", authorName: "", name: "Japanese 101", description: "Some long description text that will fill the text rectangle box.", primaryLanguage: "JPN", secondaryLanguage: "ENG", tags: ["Beginner", "Pro", "Noob"], cardsCount: 92))
            ]),
            
            .init(type: .randomCollection, title: "Random Collections", items: []),
            
            .init(type: .recentCard, title: "Random Cards", items: []),
        ]
        return model
    }()
    
    static var placeholder: CommunityViewModel {
        let model = CommunityViewModel()
        
        let collections = (1...9).map { number -> PublicSectionItem in
            let collectionID = "collection\(number)"
            let collection = PublicCollection(collectionID: collectionID, authorID: "----", authorName: "", name: "---------", description: "----", primaryLanguage: "---", secondaryLanguage: "---", tags: [], cardsCount: 0)
            let item = PublicSectionItem(itemID: collectionID, object: collection)
            return item
        }
        
        let cards = (1...9).map { number -> PublicSectionItem in
            let collectionID = "collection\(number)"
            let cardID = "card\(number)"
            let card = PublicNoteCard(collectionID: collectionID, cardID: cardID, native: "----", translation: "----", favorited: false, formality: 0, note: "----", tags: [], relationships: [])
            let item = PublicSectionItem(itemID: cardID, object: card)
            return item
        }
        
        model.sections = [
            .init(type: .recentCollection, title: "Recent Collections", items: collections),
            .init(type: .recentCard, title: "Recent Cards", items: cards)
        ]
        
        return model
    }
}
