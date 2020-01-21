//
//  HomeView.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct HomeView: View {
    
    @State private var currentTab = MainTabView.Tab.card
    
    @State private var noteCardCollectionViewModel = NoteCardCollectionViewModel()
    
    @State private var currentCollectionID: String? = AppCache.currentCollectionUUID
    
    @FetchRequest(fetchRequest: NoteCard.requestNoteCards(forCollectionUUID: AppCache.currentCollectionUUID ?? ""))
    var noteCards
    
    @FetchRequest(fetchRequest: NoteCardCollection.requestAllCollections())
    var collections
    
    @FetchRequest(fetchRequest: NoteCardCollection.requestCollection(withUUID: AppCache.currentCollectionUUID ?? ""))
    var collection
    
    @FetchRequest(fetchRequest: Tag.requestAllTags())
    var tags
    
    
    var body: some View {
        TabView(selection: $currentTab) {
            
            // MARK: Card Tab
            HomeNoteCardView(
                viewModel: noteCardCollectionViewModel,
                collection: Array(collection).first!,
                allCollections: Array(collections),
                allTags: Array(tags),
                updateContext: CoreDataStack.current.mainContext
            )
                .tabItem(MainTabView.Tab.card.tabItem)
                .tag(MainTabView.Tab.card)
            
            // MARK: Collection Tab
            HomeNoteCardCollectionView(
                collections: Array(collections),
                currentCollectionID: $currentCollectionID,
                onCurrentCollectionChanged: nil
            )
                .tabItem(MainTabView.Tab.collection.tabItem)
                .tag(MainTabView.Tab.collection)
            
            // MARK: Tag Tab
            HomeTagView(tags: Array(tags))
                .tabItem(MainTabView.Tab.tag.tabItem)
                .tag(MainTabView.Tab.tag)
            
        }
        .onAppear(perform: setupHomeViewAppear)
    }
}


extension HomeView {
    
    func setupHomeViewAppear() {
        noteCardCollectionViewModel.noteCards = Array(noteCards)
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
