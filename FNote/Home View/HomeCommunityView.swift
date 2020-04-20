//
//  HomeCommunityView.swift
//  FNote
//
//  Created by Dara Beng on 2/28/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit


struct HomeCommunityView: View {
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.sizeCategory) private var sizeCategory
    
    @EnvironmentObject private var appState: AppState
    
    var viewModel: PublicCollectionViewModel
    
    @State private var trayViewModel = BDButtonTrayViewModel()
    
    @State private var sheet = PresentingSheet<Sheet>()
    @State private var publishFormModel: PublishCollectionFormModel?
    
    @State private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    @State private var isFetchingData = false
        
    var horizontalSizeClasses: [UserInterfaceSizeClass] {
        [horizontalSizeClass!]
    }
    
    var sizeCategories: [ContentSizeCategory] {
        [sizeCategory]
    }
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                CollectionViewWrapper(viewModel: viewModel, collectionView: collectionView)
                    .edgesIgnoringSafeArea(.all)
            }
            .navigationBarTitle("Communities")
            .overlay(buttonTrayView, alignment: .bottomTrailing)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(horizontalSizeClasses.publisher, perform: handleSizeClassChanged)
        .onReceive(sizeCategories.publisher, perform: handleSizeCategoryChanged)
        .onAppear(perform: setupOnAppear)
        .sheet(item: $sheet.presenting, content: presentationSheet)
    }
}


extension HomeCommunityView {
    
    func setupOnAppear() {
        setupViewModel()
        setupTrayViewModel()
    }
    
    func setupViewModel() {
        viewModel.lastSectionContentInsets.bottom = 140
        viewModel.fetchData { error in
            guard let error = error else { return }
            print("failed to fetch data with error: \(error)")
        }
        
        viewModel.onItemSelected = { item, section in
            switch section {
            case .recentCard:
                let card = item.object as! PublicNoteCard
                self.handleRecentCardSelected(card)
            case .recentCollection:
                let collection = item.object as! PublicCollection
                self.handleRecentCollectionSelected(collection)
            case .randomCollection, .action: break
            }
        }
    }
    
    func handleSizeClassChanged(with sizeClass: UserInterfaceSizeClass) {
        if viewModel.dataSource == nil {
            viewModel.setupCollectionView(collectionView)
        }
        viewModel.isHorizontallyCompact = horizontalSizeClass == .compact
        collectionView.collectionViewLayout.invalidateLayout()
        viewModel.updateSnapshot(animated: false, completion: nil)
    }
    
    func handleSizeCategoryChanged(with size: ContentSizeCategory) {
        guard let dataSource = viewModel.dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot)
    }
    
    func handleRecentCardSelected(_ card: PublicNoteCard) {
        guard card.relationships.isEmpty == false else {
            print("card \(card.native) has no relationships")
            return
        }
        PublicRecordManager.shared.queryCards(withIDs: card.relationships) { result in
            switch result {
            case .success(let records):
                let cards = records.map({ PublicNoteCard(record: $0) })
                cards.forEach({ print($0) })
            case .failure(let error):
                print("⚠️ failed to fetch relationship card with error: \(error) ⚠️")
            }
        }
    }
    
    func handleRecentCollectionSelected(_ collection: PublicCollection) {
        let senderID = collection.authorID
        let receiverID = collection.collectionID
        let recordManager = PublicRecordManager.shared
        recordManager.sendLikeToken(senderID: senderID, receiverID: receiverID, token: .like) { result in
            
        }
    }
}



// MARK: - Button Tray View

extension HomeCommunityView {
    
    var buttonTrayView: some View {
        BDButtonTrayView(viewModel: trayViewModel)
            .padding(16)
    }
    
    func setupTrayViewModel() {
        trayViewModel.setDefaultColors()
        trayViewModel.mainItem = createTrayMainItem()
        trayViewModel.items = createTrayItems()
    }
    
    func createTrayMainItem() -> BDButtonTrayItem {
        BDButtonTrayItem(title: "", systemImage: "arrow.2.circlepath") { item in
            guard self.isFetchingData == false else { return }
            self.trayViewModel.mainItem.disabled = true
            self.isFetchingData = true
            self.viewModel.fetchData { error in
                self.isFetchingData = false
                self.trayViewModel.mainItem.disabled = false
            }
        }
    }
    
    func createTrayItems() -> [BDButtonTrayItem] {
        let publish = BDButtonTrayItem(title: "Publish Collection", systemImage: "rectangle.stack.badge.person.crop") { item in
            self.trayViewModel.expanded = false
            self.beginPublishCollection()
        }
        
        let search = BDButtonTrayItem(title: "Search", systemImage: "magnifyingglass") { item in
            print(item.title)
        }
        
        let filter = BDButtonTrayItem(title: "Filter", systemImage: "slider.horizontal.3") { item in
            print(item.title)
        }
        
        let updateUserItem = { (item: BDButtonTrayItem) in
            let username = AppCache.username
            let image = username.isEmpty ? "person.crop.circle.badge.exclam" : "person.crop.circle.badge.checkmark"
            item.title = username
            item.systemImage = image
            item.activeColor = username.isEmpty ? .red : nil
        }
    
        let user = BDButtonTrayItem(title: "", systemImage: "") { item in
            updateUserItem(item)
            print(AppCache.userAbout)
        }
        
        updateUserItem(user)
        
        return [publish, search, filter, user]
    }
}


// MARK: - Sheet

extension HomeCommunityView {
    
    enum Sheet: PresentingSheetEnum {
        case publishCollection
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .publishCollection:
            return PublishCollectionForm(viewModel: self.publishFormModel!)
        }
    }
}


// MARK: - Publish Collection

extension HomeCommunityView {
    
    func beginPublishCollection() {
        let formModel = PublishCollectionFormModel()
        formModel.commitTitle = "PUBLISH"
        
        formModel.selectableCollections = appState.collections
        formModel.onCommit = commitPublishCollection
        
        formModel.onCancel = {
            self.publishFormModel = nil
            self.sheet.dismiss()
        }
        
        formModel.onPublicUserFetched = { user in
            formModel.authorName = user.username
            formModel.author = user
        }
        
        formModel.onPublishStateChanged = { state in
            switch state {
            case .editing: formModel.commitTitle = "PUBLISH"
            case .submitting: formModel.commitTitle = "PUBLISHING"
            case .rejected: formModel.commitTitle = "FAILED"
            case .published:
                self.publishFormModel = nil
                self.sheet.dismiss()
            }
        }
        
        publishFormModel = formModel
        sheet.present(.publishCollection)
    }
    
    func commitPublishCollection() {
        publishFormModel?.validateInputs()
        
        guard let formModel = publishFormModel, formModel.hasValidInputs else { return }
        guard let collection = formModel.publishCollection else { return }
        guard let primaryLanguage = formModel.publishPrimaryLanguage else { return }
        guard let secondaryLanguage = formModel.publishSecondaryLanguage else { return }
        guard let user = formModel.author else { return }
        
        // create ID map for public card and use it to set relationships
        // map value is [localID: publicID]
        var cardIDMap = [String: String]()
        for noteCard in collection.noteCards {
            let localID = noteCard.uuid
            let publicID = UUID().uuidString
            cardIDMap[localID] = publicID
        }
        
        // create a new public collection ID
        let publicCollectionID = UUID().uuidString
        
        // unwrapping the map is safe here
        let publicCards = collection.noteCards.map { noteCard -> PublicNoteCard in
            let localID = noteCard.uuid
            let publicID = cardIDMap[localID]!
            let publicRelationshipIDs = noteCard.relationships.map({ cardIDMap[$0.uuid]! })
            let publicTags = noteCard.tags.map(\.name).sorted()
            let publicNote = formModel.includesNote ? noteCard.note : ""
            
            let publicCard = PublicNoteCard(
                collectionID: publicCollectionID,
                cardID: publicID,
                native: noteCard.native,
                translation: noteCard.translation,
                favorited: noteCard.isFavorite,
                formality: Int(noteCard.formality.rawValue),
                note: publicNote,
                tags: publicTags,
                relationships: publicRelationshipIDs
            )
            return publicCard
        }
        
        let publicCollection = PublicCollection(
            collectionID: publicCollectionID,
            authorID: user.userID,
            name: formModel.publishCollectionName,
            description: formModel.publishDescription,
            primaryLanguage: primaryLanguage.code,
            secondaryLanguage: secondaryLanguage.code,
            tags: formModel.publishTags,
            cardsCount: publicCards.count
        )
        
        formModel.setPublishState(to: .submitting)
        
        let recordManager = PublicRecordManager.shared
        recordManager.upload(collection: publicCollection, with: publicCards) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    formModel.setPublishState(to: .published)
                case .failure(let error):
                    print(error)
                    formModel.setPublishState(to: .rejected)
                }
            }
        }
        
        // update username if changed
        guard user.username != formModel.authorName, let record = user.record else { return }
        let usernameKey = PublicUser.RecordKeys.username.stringValue
        record[usernameKey] = formModel.authorName
        recordManager.save(record: record) { result in
            print("📝 updated username with result: \(result) 📝")
        }
    }
}


struct HomeCommunityView_Previews: PreviewProvider {
    static var viewModel = PublicCollectionViewModel()
    static var previews: some View {
        HomeCommunityView(viewModel: viewModel)
            .environment(\.horizontalSizeClass, .regular)
    }
}
