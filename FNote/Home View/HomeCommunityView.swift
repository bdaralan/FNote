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
    
    var horizontalSizeClasses: [UserInterfaceSizeClass] {
        [horizontalSizeClass!]
    }
    
    var sizeCategories: [ContentSizeCategory] {
        [sizeCategory]
    }
    
    
    var body: some View {
        NavigationView {
            CollectionViewWrapper(viewModel: viewModel, collectionView: collectionView)
                .navigationBarTitle("Communities")
                .navigationBarItems(trailing: trailingNavItems)
                .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(horizontalSizeClasses.publisher, perform: configureCollectionView)
        .onReceive(sizeCategories.publisher, perform: handleSizeCategoryChanged)
        .onAppear(perform: setupOnAppear)
        .sheet(isPresented: $showPublishForm, content: { PublishCollectionForm(viewModel: self.publishFormModel!) })
    }
}


extension HomeCommunityView {
    
    func setupOnAppear() {
        viewModel.sections = [
            .init(type: .recentCollection, title: "", items: []),
            .init(type: .recentCard, title: "", items: [])
        ]
        viewModel.fetchRecentCollections(completedWithError: nil)
        viewModel.fetchRecentNoteCards(completedWithError: nil)
//        viewModel.onSectionScrolled = handleSectionScrolled
    }
    
    func configureCollectionView(with sizeClass: UserInterfaceSizeClass) {
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
        print(section, offset)
    }
}


extension HomeCommunityView {
    
    var trailingNavItems: some View {
        HStack(spacing: 8) {
            NavigationBarButton(imageName: "magnifyingglass", action: {})
            NavigationBarButton(imageName: "rectangle.stack.badge.plus", action: {
                self.publishFormModel = .init()
                self.publishFormModel?.onCancel = {
                    self.publishFormModel = nil
                    self.showPublishForm = false
                }
                self.showPublishForm = true
            })
        }
    }
}


struct HomeCommunityView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCommunityView(viewModel: PublicCollectionViewModel())
    }
}
