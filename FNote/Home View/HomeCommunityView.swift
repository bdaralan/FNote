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
        fetchData(initiated: nil, completion: nil)
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
        guard let userTrayItem = trayViewModel.items.first(where: { $0.id == userTrayItemID }) else { return }
        let user = AppCache.cachedUser()
        updateUserTrayItem(item: userTrayItem, user: user)
        publicUserViewModel?.update(with: user)
        publishFormModel?.author = user
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
    
    func createTrayItems() -> [BDButtonTrayItem] {
        let user = BDButtonTrayItem(id: userTrayItemID, title: "", systemImage: "") { item in
            self.presentPublicUserProfile(sender: item)
        }
        
        let publish = BDButtonTrayItem(title: "Publish Collection", systemImage: SFSymbol.publishCollection) { item in
            self.beginPublishCollection()
        }
        
        let refresh = BDButtonTrayItem(title: "Refresh", systemImage: SFSymbol.refresh) { item in
            self.fetchData(initiated: {
                self.setTrayItemRefreshState(item: item, refreshing: true)
            }, completion: { error in
                self.setTrayItemRefreshState(item: item, refreshing: false)
            })
        }
        
        updateUserTrayItem(item: user, user: AppCache.cachedUser())
        
        return [user, publish, refresh]
    }
    
    func setTrayItemRefreshState(item: BDButtonTrayItem, refreshing: Bool) {
        item.title = refreshing ? "Refreshing..." : "Refresh"
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
        HomeCommunityView()
            .environment(\.horizontalSizeClass, .regular)
    }
}
