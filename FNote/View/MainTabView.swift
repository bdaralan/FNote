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
        let dataSource = NoteCardCollectionDataSource.init(parentContext: CoreDataStack.current.mainContext)
        return dataSource
    }()
    
    @State private var currentTabItem = Tab.home
    
    var collection = NoteCardCollection.sampleCollections(count: 1, noteCount: 20)[0]
    
    var currentTabItemTag: Binding<Int> {
        .init(
            get: { self.currentTabItem.rawValue },
            set: { self.currentTabItem = Tab(rawValue: $0)! }
        )
    }
    
    var body: some View {
        TabView(selection: currentTabItemTag) {
            NoteCardCollectionView(collection: collection).tabItem {
                createTabItem(name: "Notes", image: Image(systemName: "rectangle.fill.on.rectangle.angled.fill"))
            }
            .environmentObject(noteCardCollectionDataSource)
            .tag(Tab.home.rawValue)
            
            Text("Collections").tabItem {
                createTabItem(name: "Collections", image: Image(systemName: "rectangle.stack.fill"))
            }
            .tag(Tab.collection.rawValue)
            
            Text("Tags").tabItem {
                createTabItem(name: "Tags", image: Image(systemName: "tag.fill"))
            }
            .tag(Tab.tag.rawValue)
            
            Text("Settings").tabItem {
                createTabItem(name: "Settings", image: Image(systemName: "gear"))
            }
            .tag(Tab.setting.rawValue)
        }
    }
}


extension MainTabView {
    
    func createTabItem(name: String, image: Image) -> some View {
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
