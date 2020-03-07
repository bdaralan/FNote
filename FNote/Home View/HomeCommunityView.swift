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
    
    @State private var collectionDownloader = PublicCollectionDownloader()
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
    }
}


extension HomeCommunityView {
    
    func setupOnAppear() {
        collectionDownloader.downloadCollections { (result) in
            switch result {
            case .success(let records):
                let collections = records.map({ PublicCollection(record: $0) })
                let collectionItems = collections.map({ PublishSectionItem(object: $0) })
                
                let section = PublishSection(type: .recentCollection, title: "Recent Collection", items: collectionItems)
                self.viewModel.updateSection(type: .recentCollection, with: section)
                DispatchQueue.main.async {
                    self.viewModel.updateSnapshot(animated: true, completion: nil)
                }
            
            case .failure(let error):
                print(error)
            }
        }
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
}


extension HomeCommunityView {
    
    var trailingNavItems: some View {
        HStack(spacing: 8) {
            NavigationBarButton(imageName: "magnifyingglass", action: {})
            NavigationBarButton(imageName: "rectangle.stack.badge.plus", action: {})
        }
    }
}


struct HomeCommunityView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCommunityView(viewModel: PublicCollectionViewModel.sample)
    }
}
