//
//  MainTabView.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct MainTabView: View {
    
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
    
    @State private var selectedNoteCardID: String?
    
    @State private var currentCollectionUUID: String?
    
    @State private var currentCollection: NoteCardCollection?
    
    let persistentStoreRemoteChangeObserver = NotificationObserver(name: .persistentStoreRemoteChange)
    
    /// A notification observer that listen to current collection did change notification.
    let collectionChangedObserver = NotificationObserver(name: .appCurrentCollectionDidChange)
    
    let collectionDeletedObserver = NotificationObserver(name: .appCollectionDidDelete)
    
    // Listener for the notification to request displaying notecard details
    let requestDisplayingNoteCardObserver = NotificationObserver(name: .requestDisplayingNoteCardDetail)
    
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $currentTabItem) {
            if currentCollection != nil {
                NoteCardCollectionView(collection: currentCollection!, selectedNoteCardID: $selectedNoteCardID)
                    .environmentObject(noteCardDataSource)
                    .environmentObject(tagDataSource)
                    .tabItem(Tab.card.tabItem)
                    .tag(Tab.card)
            } else {
                Text("No Collection")
                    .tabItem(Tab.card.tabItem)
                    .tag(Tab.card)
            }
            
            NoteCardCollectionListView(
                currentCollectionUUID: $currentCollectionUUID,
                onCollectionSelected: setCurrentCollection
            )
                .environmentObject(noteCardCollectionDataSource)
                .tabItem(Tab.collection.tabItem)
                .tag(Tab.collection)
            
            TagListView()
            .environmentObject(tagDataSource)
                .tabItem(Tab.tag.tabItem)
                .tag(Tab.tag)
            
            ProfileView(setting: .current)
                .environmentObject(noteCardCollectionDataSource)
                .environmentObject(tagDataSource)
                .tabItem(Tab.profile.tabItem)
                .tag(Tab.profile)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: setupView)
    }
}


// MARK: Setup

extension MainTabView {
    
    func setupView() {
        loadCurrentCollection()
        setupPersistentStoreRemoteChangeObserver()
        setupRequestDisplayingNoteCardObserver()
        setupCollectionObserver()
    }
    
    func setupPersistentStoreRemoteChangeObserver() {
        persistentStoreRemoteChangeObserver.onReceived = refreshFetchedObjects
    }
    
    func refreshFetchedObjects(withRemoteChange notification: Notification) {
        let history = CoreDataStack.current.historyTracker
        guard let newHistoryToken = history.token(fromRemoteChange: notification) else { return }
        guard !newHistoryToken.isEqual(history.lastToken) else { return }
        history.updateLastToken(newHistoryToken)
        
        DispatchQueue.main.async {
            switch self.currentTabItem {
            case .card:
                self.noteCardDataSource.refreshFetchedObjects()
            case .collection:
                self.noteCardCollectionDataSource.refreshFetchedObjects()
            case .tag:
                self.tagDataSource.refreshFetchedObjects()
            case .profile:
                break
            }
        }
    }
    
    /// Setup current collection observer action.
    func setupCollectionObserver() {
        collectionChangedObserver.onReceived = { notification in
            if let collection = notification.object as? NoteCardCollection {
                self.setCurrentCollection(collection)
            } else {
                self.setCurrentCollection(nil)
            }
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
            self.selectedNoteCardID = noteCard.uuid
        }
    }
    
    /// Set the current collection.
    /// - Parameter collection: The collection to be set.
    func setCurrentCollection(_ collection: NoteCardCollection?) {
        guard let collection = collection else {
            currentCollection = nil
            currentCollectionUUID = nil
            noteCardDataSource.performFetch(NoteCard.requestNone())
            return
        }
        
        guard currentCollectionUUID != collection.uuid else { return }
        
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
