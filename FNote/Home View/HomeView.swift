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
    
    @State private var cardCollectionViewModel = NoteCardCollectionViewModel()
    @State private var collectionCollectionViewModel = NoteCardCollectionCollectionViewModel()
    
    @State private var currentCollectionID: String? = AppCache.currentCollectionUUID
    
    @State private var showCreateCollectionSheet = false
    @State private var modalTextFieldModel = ModalTextFieldModel()
    
    
    var body: some View {
        TabView(selection: $currentTab) {
            
            // MARK: Card Tab
            if appState.currentCollection != nil && appState.iCloudActive {
                HomeNoteCardView(
                    viewModel: cardCollectionViewModel,
                    collection: appState.currentCollection!
                )
                    .tabItem(MainTabView.Tab.card.tabItem)
                    .tag(MainTabView.Tab.card)
            
            } else {
                WelcomeGuideView(
                    iCloudActive: appState.iCloudActive,
                    action: beginCreateNoteCardCollection
                )
                    .tabItem(MainTabView.Tab.card.tabItem)
                    .tag(MainTabView.Tab.card)
            }
            
            // MARK: Collection Tab
            HomeNoteCardCollectionView(viewModel: collectionCollectionViewModel)
                .tabItem(MainTabView.Tab.collection.tabItem)
                .tag(MainTabView.Tab.collection)
            
            // MARK: Tag Tab
            HomeTagView(tags: appState.tags)
                .tabItem(MainTabView.Tab.tag.tabItem)
                .tag(MainTabView.Tab.tag)
            
        }
        .onAppear(perform: setupOnAppear)
        .sheet(isPresented: $showCreateCollectionSheet, content: createCollectionSheet)
    }
}


// MARK: - On Appear

extension HomeView {
    
    func setupOnAppear() {
        
    }
}


// MARK: - Create Collection

extension HomeView {
    
    func createCollectionSheet() -> some View {
        ModalTextField(viewModel: $modalTextFieldModel)
    }
    
    func beginCreateNoteCardCollection() {
        modalTextFieldModel.title = "New Collection"
        modalTextFieldModel.text = ""
        modalTextFieldModel.placeholder = "Collection Name"
        modalTextFieldModel.isFirstResponder = true
        modalTextFieldModel.onCommit = commitCreateNoteCardCollection
        showCreateCollectionSheet = true
    }
    
    func commitCreateNoteCardCollection() {
        let name = modalTextFieldModel.text.trimmed()
        
        guard !name.isEmpty else {
            showCreateCollectionSheet = false
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
            showCreateCollectionSheet = false
            
        case .failed: // TODO: inform user if needed
            modalTextFieldModel.prompt = "Duplicate collection name!"
            modalTextFieldModel.promptColor = .red
            
        case .updated, .deleted, .unchanged:
            fatalError("🧨 hmm... tried to \(result) collection in commitCreateNoteCardCollection method 🧨")
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
