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
    
    var viewModel: CommunityViewModel
    
    @State private var trayViewModel = BDButtonTrayViewModel()
    
    @State private var sheet = BDPresentationItem<Sheet>()
    @State private var publishFormModel: PublishCollectionFormModel?
    @State private var publicUserViewModel: PublicUserViewModel?
    
    @State private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    @State private var isFetchingData = false
        
    var horizontalSizeClasses: [UserInterfaceSizeClass] {
        [horizontalSizeClass!]
    }
    
    var sizeCategories: [ContentSizeCategory] {
        [sizeCategory]
    }
    
    let userTrayItemID = "publicUserTrayItemID"
    
    let cachedUserDidUpdate = NotificationCenter.default.publisher(for: AppCache.nEncodedPublicUserDidChange)
    
    
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
        .onAppear(perform: setupOnAppear)
        .sheet(item: $sheet.current, onDismiss: handleSheetDismissed, content: presentationSheet)
        .onReceive(horizontalSizeClasses.publisher, perform: handleSizeClassChanged)
        .onReceive(sizeCategories.publisher, perform: handleSizeCategoryChanged)
        .onReceive(cachedUserDidUpdate.receive(on: DispatchQueue.main), perform: handlePublicUserDidUpdate)
    }
}


extension HomeCommunityView {
    
    func setupOnAppear() {
        setupViewModel()
        setupTrayViewModel()
        
        viewModel.fetchData { error in
            guard let error = error else { return }
            print("failed to fetch data with error: \(error)")
        }
    }
    
    func setupViewModel() {
        viewModel.lastSectionContentInsets.bottom = 140
        
        viewModel.onItemSelected = { item, section in
            switch section {
            case .recentCard:
                let card = item.object as! PublicCard
                self.handleRecentCardSelected(card)
            case .recentCollection:
                let collection = item.object as! PublicCollection
                self.handleRecentCollectionSelected(collection)
            case .randomCollection, .action: break
            }
        }
        
        viewModel.onVoteTriggered = { collectionCell in
            self.handleVoteTriggered(for: collectionCell)
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
    
    func handlePublicUserDidUpdate(notification: Notification) {
        guard let userTrayItem = trayViewModel.items.first(where: { $0.id == userTrayItemID }) else { return }
        let user = AppCache.cachedUser()
        updateUserTrayItem(item: userTrayItem, user: user)
        publicUserViewModel?.update(with: user)
        publishFormModel?.author = user
    }
    
    func handleRecentCardSelected(_ card: PublicCard) {
        guard card.relationships.isEmpty == false else {
            print("card \(card.native) has no relationships")
            return
        }
        PublicRecordManager.shared.queryCards(withIDs: card.relationships) { result in
            switch result {
            case .success(let records):
                let cards = records.map({ PublicCard(record: $0) })
                cards.forEach({ print($0) })
            case .failure(let error):
                print("⚠️ failed to fetch relationship card with error: \(error) ⚠️")
            }
        }
    }
    
    func handleRecentCollectionSelected(_ collection: PublicCollection) {
        // check placeholder collection
        guard UUID(uuidString: collection.collectionID) != nil else { return }
        sheet.present(.collectionDetail(collection))
    }
    
    func handleVoteTriggered(for cell: PublicCollectionCell) {
        let user = AppCache.cachedUser()
        guard user.isValid else { return }
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard let cellItem = viewModel.dataSource.itemIdentifier(for: indexPath) else { return }
        
        // unwrapped instead of guard because it must give a collection
        // otherwise, the app is not setup correctly
        var collection = cellItem.object as! PublicCollection
        
        guard UUID(uuidString: collection.collectionID) != nil else { return }
        
        // update UI immediately, but will update again after getting the result
        cell.setVoted(!collection.localVoted)
        
        PublicRecordManager.shared.sendLike(senderID: user.userID, receiverID: collection.collectionID, token: .like) { result in
            guard case .success(let liked) = result else { return }
            collection.localVoted = liked
            
            let updatedItem = PublicSectionItem(itemID: collection.collectionID, object: collection)
            for section in self.viewModel.sections.indices {
                for (index, item) in self.viewModel.sections[section].items.enumerated() {
                    if item.itemID == collection.collectionID {
                        self.viewModel.sections[section].items[index] = updatedItem
                        DispatchQueue.main.async {
                            self.viewModel.updateSnapshot(animated: false, completion: nil)
                        }
                        return
                    }
                }
            }
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
        trayViewModel.shouldDisableMainItemWhenExpanded = false
        
        trayViewModel.items = createTrayItems()
        
        trayViewModel.mainItem = .init(title: "", systemImage: SFSymbol.search) { item in
            self.sheet.present(.search)
        }
    }
    
    func createTrayMainItem() -> BDButtonTrayItem {
        BDButtonTrayItem(title: "", systemImage: SFSymbol.refresh) { item in
            guard self.isFetchingData == false else { return }
            self.isFetchingData = true
            item.disabled = true
            item.animation = .rotation()
            
            self.viewModel.fetchData { error in
                // TODO: inform error if needed
                self.isFetchingData = false
                item.disabled = false
                item.animation = nil
            }
        }
    }
    
    func createTrayItems() -> [BDButtonTrayItem] {
        let user = BDButtonTrayItem(id: userTrayItemID, title: "", systemImage: "") { item in
            self.presentPublicUserProfile(sender: item)
        }
        
        let publish = BDButtonTrayItem(title: "Publish Collection", systemImage: SFSymbol.publishCollection) { item in
            self.beginPublishCollection()
        }
        
        let refresh = BDButtonTrayItem(title: "Refresh", systemImage: SFSymbol.refresh) { item in
            guard self.isFetchingData == false else { return }
            self.isFetchingData = true
            self.setTrayItemRefreshState(item: item, refreshing: true)
            self.viewModel.fetchData { error in
                // TODO: inform error if needed
                self.isFetchingData = false
                self.setTrayItemRefreshState(item: item, refreshing: false)
            }
        }
        
        updateUserTrayItem(item: user, user: AppCache.cachedUser())
        
        return [user, publish, refresh]
    }
    
    func setTrayItemRefreshState(item: BDButtonTrayItem, refreshing: Bool) {
        item.title = refreshing ? "Refreshing..." : "Refresh"
//        item.systemImage = refreshing ? SFSymbol.loading : SFSymbol.refresh
        item.animation = refreshing ? .rotation(duration: 0.7) : nil
        item.disabled = refreshing ? true : false
        item.inactiveColor = refreshing ? .appAccent : nil
    }
    
    func updateUserTrayItem(item: BDButtonTrayItem, user: PublicUser) {
        if user.isValid {
            item.title = user.username
            item.systemImage = SFSymbol.validUser
            item.activeColor = .green
            item.disabled = false
            item.animation = nil
        
        } else {
            item.systemImage = SFSymbol.invalidUser
            item.activeColor = .red
            item.animation = .pulse()
            
            if user.userID.isEmpty {
                item.title = "failed to load profile"
            } else if user.username.isEmpty {
                item.title = "username required"
            } else {
                item.disabled = true
            }
        }
    }
    
    func presentPublicUserProfile(sender: BDButtonTrayItem) {
        let user = AppCache.cachedUser()
        let model = PublicUserViewModel(user: user)
        
        model.onDone = {
            self.publicUserViewModel = nil
            self.sheet.dismiss()
        }
        
        model.onUserUpdated = { user in
            model.disableUserInteraction = false
            model.update(with: user)
            self.updateUserTrayItem(item: sender, user: user)
            AppCache.cacheUser(user)
        }
        
        model.onUserUpdateFailed = { error in
            model.disableUserInteraction = false
        }
        
        publicUserViewModel = model
        sheet.present(.user)
    }
}


// MARK: - Sheet

extension HomeCommunityView {
    
    enum Sheet: BDPresentationSheetItem {
        case publishCollection
        case user
        case search
        case collectionDetail(PublicCollection)
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .publishCollection:
            return PublishCollectionForm(viewModel: self.publishFormModel!)
                .eraseToAnyView()
        
        case .user:
            return PublicUserView(viewModel: publicUserViewModel!)
                .eraseToAnyView()
        
        case .search:
            return PublicRecordSearchView(
                context: appState.parentContext,
                onCancel: { self.sheet.dismiss() }
            )
                .eraseToAnyView()
            
        case .collectionDetail(let collection):
            return PublicCollectionDetailView(
                collection: collection,
                context: appState.parentContext,
                onAddToCollection: nil,
                onDismiss: { self.sheet.dismiss() }
            )
                .eraseToAnyView()
        }
    }
    
    func handleSheetDismissed() {
        switch sheet.previous {
        case .publishCollection, .search, .collectionDetail, nil: break
        case .user: publicUserViewModel = nil
        }
    }
}


// MARK: - Publish Collection

extension HomeCommunityView {
    
    func beginPublishCollection() {
        let user = AppCache.cachedUser()
        let formModel = PublishCollectionFormModel(user: user)
        formModel.commitTitle = "PUBLISH"
        
        formModel.selectableCollections = appState.collections
        formModel.onCommit = commitPublishCollection
        
        formModel.onCancel = {
            self.publishFormModel = nil
            self.sheet.dismiss()
        }
        
        formModel.onPublishStateChanged = { state in
            switch state {
            case .preparing:
                formModel.commitTitle = "PUBLISH"
            case .publishing:
                formModel.commitTitle = "PUBLISHING"
            case .failed:
                formModel.commitTitle = "FAILED"
            case .published:
                self.trayViewModel.expanded = false
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
        guard formModel.publishState == .preparing else { return }
        formModel.publishState = .publishing
        
        guard let collection = formModel.publishCollection else { return }
        guard let primaryLanguage = formModel.publishPrimaryLanguage else { return }
        guard let secondaryLanguage = formModel.publishSecondaryLanguage else { return }
        
        let collectionID = UUID().uuidString
        let noteCards = collection.noteCards
        let includeNote = formModel.includesNote
        
        let publicCards = ObjectGenerator.generatePublicCards(
            from: noteCards,
            collectionID: collectionID,
            includeNote: includeNote
        )
        
        let publicCollection = PublicCollection(
            collectionID: collectionID,
            authorID: formModel.author.userID,
            authorName: formModel.author.username,
            name: formModel.publishCollectionName,
            description: formModel.publishDescription,
            primaryLanguageCode: primaryLanguage.code,
            secondaryLanguageCode: secondaryLanguage.code,
            tags: formModel.publishTags,
            cardsCount: publicCards.count
        )
        
        let recordManager = PublicRecordManager.shared
        recordManager.upload(collection: publicCollection, with: publicCards) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    formModel.publishState = .published
                case .failure:
                    formModel.publishState = .failed
                }
            }
        }
    }
}


struct HomeCommunityView_Previews: PreviewProvider {
    static var viewModel = CommunityViewModel()
    static var previews: some View {
        HomeCommunityView(viewModel: viewModel)
            .environment(\.horizontalSizeClass, .regular)
    }
}
