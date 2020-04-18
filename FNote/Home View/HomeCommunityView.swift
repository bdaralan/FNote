//
//  HomeCommunityView.swift
//  FNote
//
//  Created by Dara Beng on 2/28/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit


struct HomeCommunityView: View {
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.sizeCategory) private var sizeCategory
    
    @EnvironmentObject private var appState: AppState
    
    var viewModel: PublicCollectionViewModel
    
    @State private var trayViewModel = BDButtonTrayViewModel()
    
    @State private var sheet = PresentingSheet<Sheet>()
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
                CollectionViewWrapper(viewModel: viewModel, collectionView: collectionView)
                    .edgesIgnoringSafeArea(.all)
            }
            .navigationBarTitle("Communities")
            .overlay(buttonTrayView, alignment: .bottomTrailing)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(horizontalSizeClasses.publisher, perform: handleSizeClassChanged)
        .onReceive(sizeCategories.publisher, perform: handleSizeCategoryChanged)
        .onAppear(perform: setupOnAppear)
        .sheet(item: $sheet.presenting, content: presentationSheet)
    }
}


extension HomeCommunityView {
    
    func setupOnAppear() {
        setupViewModel()
        setupTrayViewModel()
    }
    
    func setupViewModel() {
        viewModel.lastSectionContentInsets.bottom = 140
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
                records.forEach {
                    let card = PublicNoteCard(record: $0)
                    print(card.native, card.note)
                }
            }
        }
    }
}



// MARK: - Button Tray View

extension HomeCommunityView {
    
    var buttonTrayView: some View {
        BDButtonTrayView(viewModel: trayViewModel)
            .padding(16)
    }
    
    func setupTrayViewModel() {
        trayViewModel.setDefaultColors()
        trayViewModel.mainItem = createTrayMainItem()
        trayViewModel.items = createTrayItems()
    }
    
    func createTrayMainItem() -> BDButtonTrayItem {
        BDButtonTrayItem(title: "", systemImage: "arrow.2.circlepath") { item in
            guard self.isFetchingData == false else { return }
            self.trayViewModel.mainItem.disabled = true
            self.isFetchingData = true
            self.viewModel.fetchData { error in
                self.isFetchingData = false
                self.trayViewModel.mainItem.disabled = false
            }
        }
    }
    
    func createTrayItems() -> [BDButtonTrayItem] {
        let publish = BDButtonTrayItem(title: "Publish Collection", systemImage: "rectangle.stack.badge.person.crop") { item in
            self.trayViewModel.expanded = false
            self.beginPublishCollection()
        }
        
        let search = BDButtonTrayItem(title: "Search", systemImage: "magnifyingglass") { item in
            print(item.title)
        }
        
        let filter = BDButtonTrayItem(title: "Filter", systemImage: "slider.horizontal.3") { item in
            print(item.title)
        }
        
        return [publish, search, filter]
    }
}


extension HomeCommunityView {
    
    enum Sheet: PresentingSheetEnum {
        case publishCollection
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .publishCollection:
            return PublishCollectionForm(viewModel: self.publishFormModel!)
        }
    }
    
    func beginPublishCollection() {
        let formModel = PublishCollectionFormModel()
        formModel.commitTitle = "PUBLISH"
        
        formModel.selectableCollections = appState.collections
        formModel.onCommit = commitPublishCollection
        
        formModel.onCancel = {
            self.publishFormModel = nil
            self.sheet.dismiss()
        }
        
        formModel.onPublicUserFetched = { user in
            formModel.authorName = user.username
            formModel.author = user
        }
        
        formModel.onPublishStateChanged = { state in
            switch state {
            case .editing: formModel.commitTitle = "PUBLISH"
            case .submitting: formModel.commitTitle = "PUBLISHING"
            case .rejected: formModel.commitTitle = "FAILED"
            case .published:
                self.publishFormModel = nil
                self.sheet.dismiss()
            }
        }
        
        publishFormModel = formModel
        sheet.present(.publishCollection)
    }
    
    func commitPublishCollection() {
        publishFormModel?.validateInputs()
        
        guard let formModel = publishFormModel, formModel.hasValidInputs else { return }
        guard let collection = formModel.publishCollection else { return }
        guard let primaryLanguage = formModel.publishPrimaryLanguage else { return }
        guard let secondaryLanguage = formModel.publishSecondaryLanguage else { return }
        guard let user = formModel.author else { return }
        
        let collectionToPublish = PublicCollection(
            collectionID: collection.uuid,
            authorID: user.userID,
            name: formModel.publishCollectionName,
            description: formModel.publishDescription,
            primaryLanguage: primaryLanguage.code,
            secondaryLanguage: secondaryLanguage.code,
            tags: formModel.publishTags,
            cardsCount: collection.noteCards.count
        )
        
        let cardsToPublish = collection.noteCards.map { noteCard in
            PublicNoteCard(
                collectionID: collectionToPublish.collectionID,
                cardID: noteCard.uuid,
                native: noteCard.native,
                translation: noteCard.translation,
                favorited: noteCard.isFavorite,
                formality: Int(noteCard.formality.rawValue),
                note: formModel.includesNote ? noteCard.note : "",
                tags: noteCard.tags.map(\.name),
                relationships: []
            )
        }
        
        formModel.setPublishState(to: .submitting)
        
        let recordManager = PublicRecordManager.shared
        recordManager.upload(collection: collectionToPublish, with: cardsToPublish) { result in
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
        
        // update username if needed
        guard user.username != formModel.authorName, let record = user.record else { return }
        let usernameKey = PublicUser.RecordKeys.username.stringValue
        record[usernameKey] = formModel.authorName
        recordManager.save(record: record) { result in
            switch result {
            case .success(let record):
                print("updated username: old(\(user.username)) new(\(record[usernameKey]!))")
                recordManager.cacheRecords([record], usingRecordKey: usernameKey)
                
            case .failure(let error):
                print("🧨 failed to update username with error: \(error) 🧨")
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
