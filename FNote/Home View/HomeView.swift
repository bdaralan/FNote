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
    
    @State private var currentTab = Tab.card
    
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
                    .tabItem(Tab.card.tabItem)
                    .tag(Tab.card)
            
            } else {
                WelcomeGuideView(
                    iCloudActive: appState.iCloudActive,
                    action: beginCreateNoteCardCollection
                )
                    .tabItem(Tab.card.tabItem)
                    .tag(Tab.card)
            }
            
            // MARK: Collection Tab
            HomeNoteCardCollectionView(viewModel: collectionCollectionViewModel)
                .tabItem(Tab.collection.tabItem)
                .tag(Tab.collection)
            
            // MARK: Tag Tab
            HomeTagView(tags: appState.tags)
                .tabItem(Tab.tag.tabItem)
                .tag(Tab.tag)
            
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


// MARK: - Tab Enum

extension HomeView {
    
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


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
