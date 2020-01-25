//
//  MainTabView.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct MainTabView: View {
    
    @State private var noteCardCollectionViewModel = NoteCardCollectionViewModel()
    
    @ObservedObject var noteCardCollectionDataSource: NoteCardCollectionDataSource = {
        let dataSource = NoteCardCollectionDataSource(parentContext: CoreDataStack.current.mainContext)
        return dataSource
    }()
    
    @ObservedObject var noteCardDataSource: NoteCardDataSource = {
        let dataSource = NoteCardDataSource(parentContext: CoreDataStack.current.mainContext)
        return dataSource
    }()
    
    @ObservedObject var tagDataSource: TagDataSource = {
        let dataSource = TagDataSource(parentContext: CoreDataStack.current.mainContext)
        dataSource.performFetch(Tag.requestAllTags())
        return dataSource
    }()
    
    @State private var currentTabItem = Tab.card
    
    @State private var displayingNoteCardID: String?
    
    @State private var currentCollectionUUID: String?
    
    @State private var currentCollection: NoteCardCollection?
    
    @State private var hasCreateNoteCardCollectionRequest = false
    
    @State private var isInvalidUser = FileManager.default.ubiquityIdentityToken == nil
    
    @ObservedObject private var viewReloader = ViewForceReloader()
        
    let noteCardSearchModel = NoteCardSearchModel()
    
    /// An observer that listen to remote data changed notification.
    let persistentStoreRemoteChangeObserver = NotificationObserver(name: .persistentStoreRemoteChange)
    
    let coreDataStackChangedObserver = NotificationObserver(name: CoreDataStack.nCoreDataStackDidChange)
    
    /// An observer that listen to current collection changed notification.
    let collectionChangedObserver = NotificationObserver(name: .appCurrentCollectionDidChange)
    
    /// An observer that listen to collection deleted notification.
    let collectionDeletedObserver = NotificationObserver(name: .appCollectionDidDelete)
    
    // An observer that listen to request displaying notecard details notification.
    let requestDisplayingNoteCardObserver = NotificationObserver(name: .requestDisplayingNoteCard)
    
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $currentTabItem) {
            if currentCollection != nil {
                NoteCardCollectionView(
                    viewModel: noteCardCollectionViewModel,
                    collection: currentCollection!,
                    selectedNoteCardID: $displayingNoteCardID,
                    noteCardSearchModel: noteCardSearchModel
                )
                    .environmentObject(noteCardDataSource)
                    .environmentObject(tagDataSource)
                    .tabItem(Tab.card.tabItem)
                    .tag(Tab.card)
            } else {
                NavigationView {
                    WelcomeGuideView(
                        iCloudActive: !isInvalidUser,
                        action: requestCreatingNoteCardCollection
                    )
                        .navigationBarTitle("FNote")
                }
                .tabItem(Tab.card.tabItem)
                .tag(Tab.card)
            }
            
            NoteCardCollectionListView(hasCreateCollectionRequest: $hasCreateNoteCardCollectionRequest)
                .environmentObject(noteCardCollectionDataSource)
                .tabItem(Tab.collection.tabItem)
                .tag(Tab.collection)
            
            TagListView()
                .environmentObject(tagDataSource)
                .tabItem(Tab.tag.tabItem)
                .tag(Tab.tag)
            
            ProfileView(setting: .current)
                .environment(\.managedObjectContext, noteCardDataSource.fetchedResult.managedObjectContext)
                .tabItem(Tab.profile.tabItem)
                .tag(Tab.profile)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: setupView)
        .disabled(isInvalidUser)
    }
}


// MARK: - Method

extension MainTabView {
    
    func requestCreatingNoteCardCollection() {
        currentTabItem = .collection
        hasCreateNoteCardCollectionRequest = true
    }
}


// MARK: Setup

extension MainTabView {
    
    func setupView() {
        setupPersistentStoreRemoteChangeObserver()
        setupCoreDataStackChangedObserver()
        setupRequestDisplayingNoteCardObserver()
        setupCollectionObserver()
        checkUserStatus()
        loadCurrentCollection()
        
        noteCardCollectionViewModel.noteCards = noteCardDataSource.fetchedObjects
    }
    
    func setupPersistentStoreRemoteChangeObserver() {
        persistentStoreRemoteChangeObserver.onReceived = { notification in
            let history = CoreDataStack.current.historyTracker
            guard let newHistoryToken = history.token(fromRemoteChange: notification) else { return }
            guard !newHistoryToken.isEqual(history.lastToken) else { return }
            history.updateLastToken(newHistoryToken)
            DispatchQueue.main.async {
                self.refreshFetchedObjects(for: self.currentTabItem)
            }
        }
    }
    
    func refreshFetchedObjects(for tab: Tab) {
        switch tab {
        
        case .card:
            noteCardDataSource.refreshFetchedObjects(sendChange: true)
            noteCardDataSource.performFetch()
            tagDataSource.refreshFetchedObjects(sendChange: true)
            tagDataSource.performFetch()
        
        case .collection:
            noteCardCollectionDataSource.refreshFetchedObjects(sendChange: true)
            noteCardCollectionDataSource.performFetch()
        
        case .tag:
            tagDataSource.refreshFetchedObjects(sendChange: true)
            tagDataSource.performFetch()
        
        case .profile:
            noteCardDataSource.refreshFetchedObjects(sendChange: true)
            noteCardDataSource.performFetch()
        }
        
        viewReloader.forceReload()
    }
    
    func setupCoreDataStackChangedObserver() {
        coreDataStackChangedObserver.onReceived = { notification in
            DispatchQueue.main.async {
                self.checkUserStatus()
                self.noteCardCollectionDataSource.performFetch()
                self.tagDataSource.performFetch()
                self.noteCardDataSource.performFetch()
                self.viewReloader.forceReload()
            }
        }
    }
    
    /// Setup current collection observer action.
    func setupCollectionObserver() {
        collectionChangedObserver.onReceived = { notification in
            guard let collection = notification.object as? NoteCardCollection else {
                self.setCurrentCollection(nil)
                return
            }
            guard collection.uuid != self.currentCollectionUUID else { return }
            self.setCurrentCollection(collection)
        }
        
        collectionDeletedObserver.onReceived = { notification in
            guard let collectionUUID = notification.object as? String else { return }
            guard collectionUUID == self.currentCollectionUUID else { return }
            self.setCurrentCollection(nil)
        }
    }
    
    func setupRequestDisplayingNoteCardObserver() {
        requestDisplayingNoteCardObserver.onReceived = { notification in
            guard let noteCard = notification.object as? NoteCard else { return }
            guard let collection = noteCard.collection else { return }
            if collection.uuid != self.currentCollectionUUID {
                self.setCurrentCollection(collection)
            }
            self.currentTabItem = .card
            self.noteCardSearchModel.setManualResults(noteCards: [noteCard])
        }
    }
    
    /// Set the current collection.
    /// - Parameter collection: The collection to be set.
    func setCurrentCollection(_ collection: NoteCardCollection?) {
        AppCache.currentCollectionUUID = collection?.uuid
        displayingNoteCardID = nil
        
        guard let collection = collection else {
            currentCollection = nil
            currentCollectionUUID = nil
            noteCardDataSource.performFetch(NoteCard.requestNone())
            return
        }
        
        let context = noteCardDataSource.fetchedResult.managedObjectContext
        currentCollection = context.object(with: collection.objectID) as? NoteCardCollection
        currentCollectionUUID = currentCollection?.uuid
        
        let request = NoteCard.requestNoteCards(forCollectionUUID: collection.uuid)
        noteCardDataSource.performFetch(request)
    }
    
    /// Get user's current selected note-card collection.
    func loadCurrentCollection() {
        if let uuid = AppCache.currentCollectionUUID {
            let context = noteCardDataSource.fetchedResult.managedObjectContext
            let collection = try? context.fetch(NoteCardCollection.requestCollection(withUUID: uuid)).first
            setCurrentCollection(collection)
        } else {
            setCurrentCollection(nil)
        }
    }
}


// MARK: - Alert

extension MainTabView {
    
    func invalidUserAlert() -> Alert {
        let title = Text("No Account Detected")
        let message = Text("Please sign in your Apple ID in Settings.")
        let dismiss = Alert.Button.default(Text("OK"))
        return Alert(title: title, message: message, dismissButton: dismiss)
    }
    
    func checkUserStatus() {
        isInvalidUser = FileManager.default.ubiquityIdentityToken == nil
        if isInvalidUser {
            currentTabItem = .card
            setCurrentCollection(nil)
        }
    }
}

// MARK: - Tab Enum

extension MainTabView {
    
    enum Tab: Int {
        case card
        case collection
        case tag
        case profile
        
        
        var title: String {
            switch self {
            case .card: return "Cards"
            case .collection: return "Collections"
            case .tag: return "Tags"
            case .profile: return "Profile"
            }
        }
        
        var systemImage: String {
            switch self {
            case .card: return "rectangle.fill.on.rectangle.angled.fill"
            case .collection: return "rectangle.stack.fill"
            case .tag: return "tag.fill"
            case .profile: return "person.fill"
            }
        }
        
        func tabItem() -> some View {
            let size: CGFloat = self == .profile ? 23 : 17
            
            let image = Image(systemName: systemImage)
                .frame(alignment: .bottom)
                .font(.system(size: size))
            
            let tabName = Text(title)
            
            return ViewBuilder.buildBlock(image, tabName)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
