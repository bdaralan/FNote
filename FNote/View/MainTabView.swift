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
    
    let persistentStoreRemoteChangeObserver = NotificationObserver(name: .persistentStoreRemoteChange)
    
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $currentTabItem) {
            NoteCardCollectionView()
                .environmentObject(noteCardDataSource)
                .environmentObject(tagDataSource)
                .tabItem(Tab.card.tabItem)
                .tag(Tab.card)
            
            NoteCardCollectionListView()
                .environmentObject(noteCardCollectionDataSource)
                .tabItem(Tab.collection.tabItem)
                .tag(Tab.collection)
            
            TagListView()
            .environmentObject(tagDataSource)
                .tabItem(Tab.tag.tabItem)
                .tag(Tab.tag)
            
            ProfileView()
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
}

// MARK: - Tab Enum

extension MainTabView {
    
    enum Tab: Int {
        case card
        case collection
        case tag
        case profile
        
        
        func tabItem() -> some View {
            switch self {
            case .card:
                return createTabViewItem(name: "Cards", systemImage: "rectangle.fill.on.rectangle.angled.fill")
            case .collection:
                return createTabViewItem(name: "Collections", systemImage: "rectangle.stack.fill")
            case .tag:
                return createTabViewItem(name: "Tags", systemImage: "tag.fill")
            case .profile:
                return createTabViewItem(name: "Profile", systemImage: "person.crop.square.fill")
            }
        }
        
        func createTabViewItem(name: String, systemImage: String) -> some View {
            ViewBuilder.buildBlock(Image(systemName: systemImage), Text(name))
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
