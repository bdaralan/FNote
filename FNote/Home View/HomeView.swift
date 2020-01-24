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
    
    
    var body: some View {
        TabView(selection: $currentTab) {
            
            // MARK: Card Tab
            if appState.currentCollection != nil {
                HomeNoteCardView(
                    viewModel: noteCardCollectionViewModel,
                    collection: appState.currentCollection!
                )
                    .tabItem(MainTabView.Tab.card.tabItem)
                    .tag(MainTabView.Tab.card)
            
            } else {
                WelcomeGuideView()
                    .tabItem(MainTabView.Tab.card.tabItem)
                    .tag(MainTabView.Tab.card)
            }
            
            // MARK: Collection Tab
            HomeNoteCardCollectionView()
                .tabItem(MainTabView.Tab.collection.tabItem)
                .tag(MainTabView.Tab.collection)
            
            // MARK: Tag Tab
            HomeTagView(tags: appState.tags)
                .tabItem(MainTabView.Tab.tag.tabItem)
                .tag(MainTabView.Tab.tag)
            
        }
        .onAppear(perform: setupOnAppear)
    }
}


// MARK: - On Appear

extension HomeView {
    
    func setupOnAppear() {
        
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
