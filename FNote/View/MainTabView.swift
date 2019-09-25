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
        return dataSource
    }()
    
    @State private var currentTabItem = Tab.home
    
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $currentTabItem) {
            NoteCardCollectionView()
                .environmentObject(noteCardDataSource)
                .environmentObject(tagDataSource)
                .tabItem(Tab.home.tabItem)
                .tag(Tab.home)
            
            NoteCardCollectionListView()
                .environmentObject(noteCardCollectionDataSource)
                .tabItem(Tab.collection.tabItem)
                .tag(Tab.collection)
            
            TagListView()
                .tabItem(Tab.tag.tabItem)
                .tag(Tab.tag)
            
            SettingView()
                .environmentObject(noteCardCollectionDataSource)
                .environmentObject(tagDataSource)
                .tabItem(Tab.setting.tabItem)
                .tag(Tab.setting)
        }
    }
}


// MARK: - Tab Enum

extension MainTabView {
    
    enum Tab: Int {
        case home
        case collection
        case tag
        case setting
        
        
        func tabItem() -> some View {
            switch self {
            case .home:
                return createTabViewItem(name: "Notes", systemImage: "rectangle.fill.on.rectangle.angled.fill")
            case .collection:
                return createTabViewItem(name: "Collections", systemImage: "rectangle.stack.fill")
            case .tag:
                return createTabViewItem(name: "Tags", systemImage: "tag.fill")
            case .setting:
                return createTabViewItem(name: "Settings", systemImage: "gear")
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
