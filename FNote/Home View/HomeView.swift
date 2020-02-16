//
//  HomeView.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct HomeView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userPreference: UserPreference
    
    @State private var currentTab = Tab.card
    
    @State private var sheet: Sheet?
    @State private var modalTextFieldModel = ModalTextFieldModel()
    
    @State private var cardCollectionViewModel = NoteCardCollectionViewModel()
    @State private var collectionCollectionViewModel = NoteCardCollectionCollectionViewModel()
    @State private var tagCollectionViewModel = TagCollectionViewModel()
    @State private var cardCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    @State private var storeRemoteChangeObserver = NotificationObserver(name: .persistentStoreRemoteChange)
    
    
    var body: some View {
        TabView(selection: $currentTab) {
            // MARK: Card Tab
            if appState.currentCollection?.managedObjectContext != nil && appState.iCloudActive {
                HomeNoteCardView(
                    viewModel: cardCollectionViewModel,
                    collection: appState.currentCollection!,
                    collectionView: cardCollectionView
                )
                    .tabItem(Tab.card.tabItem)
                    .tag(Tab.card)
            
            } else {
                WelcomeGuideView(
                    iCloudActive: appState.iCloudActive,
                    action: beginCreateNoteCardCollection
                )
                    .tabItem(Tab.card.tabItem)
                    .tag(Tab.card)
            }
            
            // MARK: Collection Tab
            HomeNoteCardCollectionView(viewModel: collectionCollectionViewModel)
                .tabItem(Tab.collection.tabItem)
                .tag(Tab.collection)
            
            // MARK: Tag Tab
            HomeTagView(viewModel: tagCollectionViewModel)
                .tabItem(Tab.tag.tabItem)
                .tag(Tab.tag)
            
            // MARK: Setting Tab
            HomeSettingView(userPreference: .shared)
                .tabItem(Tab.setting.tabItem)
                .tag(Tab.setting)
            
        }
        .onAppear(perform: setupOnAppear)
        .sheet(item: $sheet, onDismiss: handleSheetDismissed, content: presentationSheet)
        .alert(isPresented: $appState.showDidCopyFileAlert, content: { .DidCopyFileAlert(fileName: appState.copiedFileName) })
        .disabled(!appState.iCloudActive)
        .onReceive(appState.$currentCollectionID, perform: handleOnReceiveCurrentCollectionID)
        .onReceive(currentTab.rawValue.description.publisher.last(), perform: handleOnReceiveCurrentTab)
    }
}


// MARK: - On Appear

extension HomeView {
    
    func setupOnAppear() {
        storeRemoteChangeObserver.onReceived = handleStoreRemoteChangeNotification
        showOnboardIfNeeded()
    }
    
    func handleOnReceiveCurrentCollectionID(_ collectionID: String?) {
        cardCollectionView = .init(frame: .zero, collectionViewLayout: .init())
        cardCollectionViewModel.setupDataSource(with: cardCollectionView)
        currentTab = .card
    }
    
    func handleOnReceiveCurrentTab(_ : Character) {
        cardCollectionViewModel.cancelSearch()
    }
    
    func showOnboardIfNeeded() {
        guard AppCache.shouldShowOnboard else { return }
        appState.lockPortraitMode = true
        sheet = .onboard
    }
    
    func dismissOnboard() {
        AppCache.shouldShowOnboard = false
        appState.lockPortraitMode = false
        sheet = nil
    }
}


extension HomeView {
    
    enum Sheet: Identifiable {
        var id: Self { self }
        case createNoteCardCollection
        case onboard
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .createNoteCardCollection:
            return ModalTextField(viewModel: $modalTextFieldModel)
                .eraseToAnyView()
        
        case .onboard:
            return OnboardView(onDismiss: dismissOnboard)
                .eraseToAnyView()
        }
    }
    
    func handleSheetDismissed() {
        dismissOnboard()
    }
}


// MARK: - Remote Changes

extension HomeView {
    
    func handleStoreRemoteChangeNotification(_ notification: Notification) {
        let coreDataStack = CoreDataStack.current
        let history = coreDataStack.historyTracker
        
        // check if need to update token
        guard let newHistoryToken = history.token(fromRemoteChange: notification) else { return }
        guard !newHistoryToken.isEqual(history.lastToken) else { return }
        
        // update token
        history.updateLastToken(newHistoryToken)
        
        // update UI if remote changed
        DispatchQueue.global(qos: .default).async {
            self.refetchObjects()
            DispatchQueue.main.async {
                self.updateModels()
                self.refreshUIs()
            }
        }
    }
    
    func refetchObjects() {
        appState.fetchCurrentNoteCards()
        appState.fetchCollections()
        appState.fetchTags()
    }
    
    func updateModels() {
        cardCollectionViewModel.noteCards = appState.currenNoteCards
        collectionCollectionViewModel.collections = appState.collections
        tagCollectionViewModel.tags = appState.tags
    }
    
    func refreshUIs() {
        switch currentTab {
        case .collection:
            collectionCollectionViewModel.updateSnapshot(animated: true)
            
        case .tag:
            tagCollectionViewModel.updateSnapshot(animated: true)
            
        case .setting:
            break
            
        case .card:
            if appState.currentCollection != nil, !cardCollectionViewModel.isSearchActive {
                cardCollectionViewModel.updateSnapshot(animated: true)
            }
        }
    }
}


// MARK: - Create Collection

extension HomeView {
    
    func beginCreateNoteCardCollection() {
        modalTextFieldModel.title = "New Collection"
        modalTextFieldModel.text = ""
        modalTextFieldModel.placeholder = "Collection Name"
        modalTextFieldModel.isFirstResponder = true
        modalTextFieldModel.onCommit = commitCreateNoteCardCollection
        sheet = .createNoteCardCollection
    }
    
    func commitCreateNoteCardCollection() {
        let name = modalTextFieldModel.text.trimmed()
        
        guard !name.isEmpty else {
            sheet = nil
            return
        }
        
        let request = NoteCardCollectionCUDRequest(name: name)
        let result = appState.createNoteCardCollection(with: request)
        
        switch result {
        case .created(let collection, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            let parentContextCollection = collection.get(from: appState.parentContext)
            appState.setCurrentCollection(parentContextCollection)
            appState.fetchCollections()
            collectionCollectionViewModel.collections = appState.collections
            sheet = nil
            
        case .failed: // TODO: inform user if needed
            modalTextFieldModel.prompt = "Duplicate collection name!"
            modalTextFieldModel.promptColor = .red
            
        case .updated, .deleted, .unchanged:
            fatalError("🧨 hmm... tried to \(result) collection in commitCreateNoteCardCollection method 🧨")
        }
    }
}


// MARK: - Tab Enum

extension HomeView {
    
    enum Tab: Int {
        case card
        case collection
        case tag
        case setting
        
        
        var title: String {
            switch self {
            case .card: return "Cards"
            case .collection: return "Collections"
            case .tag: return "Tags"
            case .setting: return "Settings"
            }
        }
        
        var systemImage: String {
            switch self {
            case .card: return "rectangle.fill.on.rectangle.angled.fill"
            case .collection: return "rectangle.stack.fill"
            case .tag: return "tag.fill"
            case .setting: return "gear"
            }
        }
        
        func tabItem() -> some View {
            let size: CGFloat = self == .setting ? 23 : 17
            
            let image = Image(systemName: systemImage)
                .frame(alignment: .bottom)
                .font(.system(size: size))
            
            let tabName = Text(title)
            
            return ViewBuilder.buildBlock(image, tabName)
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
