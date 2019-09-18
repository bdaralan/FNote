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
    
    var collection = NoteCardCollection.sampleCollections(count: 1, noteCount: 20)[0]
    
    
    var body: some View {
        TabView(selection: $currentTabItem) {
            NoteCardCollectionView(collection: collection).tabItem {
                createTabViewItem(name: "Notes", image: Image(systemName: "rectangle.fill.on.rectangle.angled.fill"))
            }
            .environmentObject(noteCardCollectionDataSource)
            .tag(Tab.home)
            
            NoteCardCollectionListView().tabItem {
                createTabViewItem(name: "Collections", image: Image(systemName: "rectangle.stack.fill"))
            }
            .environmentObject(noteCardCollectionDataSource)
            .tag(Tab.collection)
            
            Text("Tags").tabItem {
                createTabViewItem(name: "Tags", image: Image(systemName: "tag.fill"))
            }
            .tag(Tab.tag)
            
            Text("Settings").tabItem {
                createTabViewItem(name: "Settings", image: Image(systemName: "gear"))
            }
            .tag(Tab.setting)
        }
    }
}


extension MainTabView {
    
    func createTabViewItem(name: String, image: Image) -> some View {
        ViewBuilder.buildBlock(image, Text(name))
    }
}


extension MainTabView {
    
    enum Tab: Int {
        case home
        case collection
        case tag
        case setting
    }
}


struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
