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
                    .navigationBarTitle("Communities")
                    .navigationBarItems(trailing: trailingNavItems)
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
        
//        viewModel.onSectionScrolled = handleSectionScrolled
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
    
    func handleSectionScrolled(section: PublicSectionType, offset: CGPoint) {
        guard section == .recentCollection, offset.x < -70 else { return }
        viewModel.fetchRecentCollections(completedWithError: nil)
        viewModel.fetchRecentNoteCards(completedWithError: nil)
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
            case .published: formModel.commitTitle = "PUBLISHED"
            case .rejected: formModel.commitTitle = "FAILED"
            }
        }
        
        publishFormModel = formModel
        showPublishForm = true
    }
    
    func commitPublishCollection() {
        guard let formModel = publishFormModel else { return }
        guard formModel.hasValidInputs, let collection = formModel.publishCollection else { return }
        
        let publicCollection = PublicCollection(
            collectionID: collection.uuid,
            authorID: formModel.authorName,
            name: collection.name,
            description: formModel.publishDescription,
            primaryLanguage: "KOR",
            secondaryLanguage: "ENG",
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


struct CommunityActionButton: View {
    
    var action: () -> Void
    
    var systemImage: String?
    
    var offsetY: CGFloat = 0
    
    var title: String
    
    var description: String?
    
    var body: some View {
        Button(action: action) {
            HStack {
                systemImage.map { name in
                    Image(systemName: name)
                    .font(Font.body.weight(.black))
                    .foregroundColor(.primary)
                    .offset(y: offsetY)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .foregroundColor(.primary)
                        .fontWeight(.black)
                        .fixedSize()
                    
                    description.map { description in
                        Text(description)
                            .foregroundColor(.secondary)
                            .font(.footnote)
                            .fixedSize()
                    }
                }
            }
                .modifier(InsetRowStyle(height: 65))
        }
    }
}
