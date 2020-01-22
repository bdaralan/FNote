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
    
    @State private var currentTab = MainTabView.Tab.card
    
    @State private var noteCardCollectionViewModel = NoteCardCollectionViewModel()
    
    @State private var currentCollectionID: String? = AppCache.currentCollectionUUID
    
    @FetchRequest(fetchRequest: NoteCardCollection.requestCollection(withUUID: AppCache.currentCollectionUUID ?? ""))
    var collection
    
    
    var body: some View {
        TabView(selection: $currentTab) {
            
            // MARK: Card Tab
            HomeNoteCardView(
                viewModel: noteCardCollectionViewModel,
                collection: Array(collection).first!
            )
                .tabItem(MainTabView.Tab.card.tabItem)
                .tag(MainTabView.Tab.card)
            
            // MARK: Collection Tab
            HomeNoteCardCollectionView(
                collections: appState.collections,
                currentCollectionID: $currentCollectionID,
                onCurrentCollectionChanged: nil
            )
                .tabItem(MainTabView.Tab.collection.tabItem)
                .tag(MainTabView.Tab.collection)
            
            // MARK: Tag Tab
            HomeTagView(tags: appState.tags)
                .tabItem(MainTabView.Tab.tag.tabItem)
                .tag(MainTabView.Tab.tag)
            
        }
        .onAppear(perform: setupHomeViewAppear)
    }
}


extension HomeView {
    
    func setupHomeViewAppear() {
        
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
