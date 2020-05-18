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
    
    @State private var viewModel = CommunityViewModel()
    
    @State private var trayViewModel = BDButtonTrayViewModel()
    
    @State private var sheet = BDPresentationItem<Sheet>()
    @State private var publishFormModel: PublishCollectionFormModel?
    @State private var publicUserViewModel: PublicUserViewModel?
    
    @State private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    @State private var isFetchingData = false
    
    @State private var user: PublicUser?
        
    var horizontalSizeClasses: [UserInterfaceSizeClass] {
        [horizontalSizeClass!]
    }
    
    var sizeCategories: [ContentSizeCategory] {
        [sizeCategory]
    }
    
    let userTrayID = "userTrayID"
    let publishTrayID = "publishTrayID"
    
    let cachedUserDidUpdate = NotificationCenter.default.publisher(for: AppCache.nPublicUserDidChange)
    
    
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
        user = AppCache.publicUser()
        setupViewModel()
        setupTrayViewModel()
        updateUserTrayItem(user: user)
        fetchData(initiated: nil, completion: nil)
        fetchUser(present: false)
    }
    
    func setupViewModel() {
        viewModel.contentInsets.bottom = 140
        
        viewModel.onCollectionSelected = { collection, section in
            self.sheet.present(.collectionDetail(collection))
        }
        
        viewModel.onCardSelected = { card, section in
            print("📝 \(card) 📝")
        }
        
        viewModel.onVoteTriggered = { cell in
            print("📝 vote \(cell.object as Any) 📝")
        }
    }
    
    func fetchData(initiated: (() -> Void)?, completion: ((Error?) -> Void)?) {
        guard isFetchingData == false else { return }
        isFetchingData = true
        
        initiated?()
        
        viewModel.fetchData { error in
            DispatchQueue.main.async { // TODO: inform error if needed
                self.viewModel.updateSnapshot(animated: false, completion: nil)
                self.isFetchingData = false
                completion?(error)
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
    
    func handlePublicUserDidUpdate(notification: Notification) {
        user = AppCache.publicUser()
        updateUserTrayItem(user: user)
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
        
        trayViewModel.mainItem = .init(title: "", image: .system(SFSymbol.search)) { item in
            self.sheet.present(.search)
        }
    }
    
    func createTrayItems() -> [BDButtonTrayItem] {
        let userItem = BDButtonTrayItem(id: userTrayID, title: "", image: .system(SFSymbol.user)) { item in
            if let user = self.user {
                self.presentUserProfile(user: user)
            } else {
                self.fetchUser(present: true)
            }
        }
        
        let publishImage = BDButtonTrayItemImage.system(SFSymbol.publishCollection)
        let publishItem = BDButtonTrayItem(id: publishTrayID, title: "Publish Collection", image: publishImage) { item in
            guard let user = self.user else { return }
            self.beginPublishCollection(author: user)
        }
        
        let refreshItem = BDButtonTrayItem(title: "Refresh", image: .system(SFSymbol.refresh)) { item in
            self.fetchData(initiated: {
                self.setTrayItemRefreshState(item: item, refreshing: true)
            }, completion: { error in
                self.setTrayItemRefreshState(item: item, refreshing: false)
            })
        }
        
        return [userItem, publishItem, refreshItem]
    }
    
    func setTrayItemRefreshState(item: BDButtonTrayItem, refreshing: Bool) {
        item.title = refreshing ? "Refreshing..." : "Refresh"
        item.animation = refreshing ? .rotation(duration: 0.7) : nil
        item.disabled = refreshing ? true : false
        item.inactiveColor = refreshing ? .appAccent : nil
    }
    
    func updateUserTrayItem(user: PublicUser?) {
        let userItem = trayViewModel.items.first(where: { $0.id == userTrayID })!
        let publishItem = trayViewModel.items.first(where: { $0.id == publishTrayID })!
        
        if let user = user {
            let noUsername = user.username.isEmpty
            userItem.title = noUsername ? "username required" : user.username
            userItem.image = .system(noUsername ? SFSymbol.invalidUser : SFSymbol.validUser)
            userItem.activeColor = noUsername ? .red : .green
            userItem.animation = noUsername ? .pulse() : nil
            publishItem.disabled = noUsername
            trayViewModel.expandIndicatorColor = noUsername ? .red : .secondary
        
        } else {
            userItem.title = "invalid user"
            userItem.image = .system(SFSymbol.invalidUser)
            userItem.activeColor = .red
            userItem.animation = .pulse()
            publishItem.disabled = true
            trayViewModel.expandIndicatorColor = .red
        }
    }
    
    func fetchUser(present: Bool) {
        PublicRecordManager.shared.fetchPublicUserRecord { result in
            switch result {
            
            case let .success(record):
                let user = PublicUser(record: record)
                AppCache.cachePublicUser(user)
                guard present else { return }
                DispatchQueue.main.async {
                    self.presentUserProfile(user: user)
                }
            
            case let .failure(error):
                print(error)
                guard error.code == .partialFailure else { return }
                AppCache.publicUserData = nil
                
                guard present else { return }
                PublicRecordManager.shared.createInitialPublicUserRecord(withData: nil) { result in
                    guard case let .success(record) = result else { return }
                    let user = PublicUser(record: record)
                    AppCache.cachePublicUser(user)
                    DispatchQueue.main.async {
                        self.presentUserProfile(user: user)
                    }
                }
            }
        }
    }
    
    func presentUserProfile(user: PublicUser) {
        let model = PublicUserViewModel(user: user)
        
        model.onDone = {
            self.publicUserViewModel = nil
            self.sheet.dismiss()
        }
        
        model.onUserUpdated = { user in
            model.disableUserInteraction = false
            model.update(with: user)
            self.user = user
            AppCache.cachePublicUser(user)
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
    
    func beginPublishCollection(author: PublicUser) {
        guard author.username.isEmpty == false else { return }
        
        let formModel = PublishCollectionFormModel(user: author)
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
        
        let publicCards = ObjectMaker.makePublicCards(
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
        HomeCommunityView()
            .environment(\.horizontalSizeClass, .regular)
    }
}
