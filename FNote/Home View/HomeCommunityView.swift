//
//  HomeCommunityView.swift
//  FNote
//
//  Created by Dara Beng on 2/28/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import CloudKit


struct HomeCommunityView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    
    var viewModel: PublicCollectionViewModel
    
    @State private var showPublishForm = false
    @State private var publishFormModel: PublishCollectionFormModel?
    
    @State private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    @State private var isFetchingData = false
        
    var horizontalSizeClasses: [UserInterfaceSizeClass] {
        [horizontalSizeClass!]
    }
    
    var sizeCategories: [ContentSizeCategory] {
        [sizeCategory]
    }
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: Collection & Card
                CollectionViewWrapper(viewModel: viewModel, collectionView: collectionView)
                    .edgesIgnoringSafeArea(.all)
                
                // MARK: Divider
                Divider()
                
                // MARK: Action Buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        CommunityActionButton(
                            action: beginPublishCollection,
                            title: "PUBLISH COLLECTION",
                            description: "share a copy of your collection with the world"
                        )
                        
                        CommunityActionButton(
                            action: handleRefreshTapped,
                            systemImage: "arrow.2.circlepath",
                            offsetY: -1,
                            title: "REFRESH"
                        )
                            .opacity(isFetchingData ? 0.4 : 1)
                            .disabled(isFetchingData)
                        
                        CommunityActionButton(
                            action: handleSearchTapped,
                            systemImage: "magnifyingglass",
                            title: "SEARCH"
                        )
                        
                        CommunityActionButton(
                            action: handleFilterTapped,
                            systemImage: "slider.horizontal.3",
                            title: "FILTER"
                        )
                    }
                    .padding(16)
                }
            }
            .navigationBarTitle("Communities")
            .navigationBarItems(trailing: trailingNavItems)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(horizontalSizeClasses.publisher, perform: handleSizeClassChanged)
        .onReceive(sizeCategories.publisher, perform: handleSizeCategoryChanged)
        .onAppear(perform: setupOnAppear)
        .sheet(isPresented: $showPublishForm, content: { PublishCollectionForm(viewModel: self.publishFormModel!) })
    }
}


extension HomeCommunityView {
    
    func setupOnAppear() {
        viewModel.fetchData { error in
            guard let error = error else { return }
            print("failed to fetch data with error: \(error)")
        }
        
        viewModel.onItemSelected = handlePublishSectionItemSelected
    }
    
    func handleSizeClassChanged(with sizeClass: UserInterfaceSizeClass) {
        if viewModel.dataSource == nil {
            viewModel.setupCollectionView(collectionView)
        }
        viewModel.isHorizontallyCompact = horizontalSizeClass == .compact
        collectionView.collectionViewLayout.invalidateLayout()
        viewModel.updateSnapshot(animated: false, completion: nil)
    }
    
    func handleSizeCategoryChanged(with size: ContentSizeCategory) {
        guard let dataSource = viewModel.dataSource else { return }
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot)
    }
    
    func handlePublishSectionItemSelected(item: PublicSectionItem, sectionType: PublicSectionType) {
        switch sectionType {
        case .randomCollection, .recentCard: break
        
        case .action:
            guard let action = item.object as? PublicSectionAction else { return }
            switch action {
            case .publishCollection:
                beginPublishCollection()
            case .refreshData:
                viewModel.fetchData(completedWithError: nil)
            }
        
        case .recentCollection:
            guard let collection = item.object as? PublicCollection else { return }
            PublicRecordManager.shared.queryCards(withCollectionID: collection.collectionID) { result in
                guard case .success(let records) = result else { return }
                print(collection.name)
                records.forEach({ print(PublicNoteCard(record: $0).native) })
            }
        }
    }
    
    func handleRefreshTapped() {
        guard !isFetchingData else { return }
        isFetchingData = true
        viewModel.fetchData { error in
            self.isFetchingData = false
        }
    }
    
    func handleSearchTapped() {
        
    }
    
    func handleFilterTapped() {
        
    }
}


extension HomeCommunityView {
    
    var trailingNavItems: some View {
        EmptyView()
    }
    
    func beginPublishCollection() {
        let formModel = PublishCollectionFormModel()
        formModel.commitTitle = "PUBLISH"
        
        formModel.onCommit = commitPublishCollection
        
        formModel.onCancel = {
            self.publishFormModel = nil
            self.showPublishForm = false
        }
        
        formModel.onPublishStateChanged = { state in
            switch state {
            case .editing: formModel.commitTitle = "PUBLISH"
            case .submitting: formModel.commitTitle = "PUBLISHING"
            case .rejected: formModel.commitTitle = "FAILED"
            case .published:
                formModel.commitTitle = "PUBLISHED"
                self.showPublishForm = false
            }
        }
        
        publishFormModel = formModel
        showPublishForm = true
    }
    
    func commitPublishCollection() {
        guard let formModel = publishFormModel, formModel.hasValidInputs else { return }
        guard let collection = formModel.publishCollection else { return }
        guard let primaryLanguage = formModel.publishPrimaryLanguage else { return }
        guard let secondaryLanguage = formModel.publishSecondaryLanguage else { return }
        
        let publicCollection = PublicCollection(
            collectionID: collection.uuid,
            authorID: formModel.authorName,
            name: collection.name,
            description: formModel.publishDescription,
            primaryLanguage: primaryLanguage.code,
            secondaryLanguage: secondaryLanguage.code,
            tags: formModel.publishTags,
            cardsCount: collection.noteCards.count
        )
        
        let cards = collection.noteCards.map { noteCard in
            PublicNoteCard(
                collectionID: publicCollection.collectionID,
                cardID: noteCard.uuid,
                native: noteCard.native,
                translation: noteCard.translation,
                favorited: noteCard.isFavorite,
                formality: Int(noteCard.formality.rawValue),
                note: noteCard.note,
                tags: noteCard.tags.map({ $0.name }),
                relationships: []
            )
        }
        
        formModel.setPublishState(to: .submitting)
        
        PublicRecordManager.shared.upload(collection: publicCollection, with: cards) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    formModel.setPublishState(to: .published)
                case .failure(let error):
                    print(error)
                    formModel.setPublishState(to: .rejected)
                }
            }
        }
    }
}


struct HomeCommunityView_Previews: PreviewProvider {
    static var viewModel = PublicCollectionViewModel()
    static var previews: some View {
        HomeCommunityView(viewModel: viewModel)
            .environment(\.horizontalSizeClass, .regular)
    }
}
