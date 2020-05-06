//
//  PublicCollectionDetailView.swift
//  FNote
//
//  Created by Dara Beng on 5/2/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit


struct PublicCollectionDetailView: View {
    
    var collection: PublicCollection
    
    var onAddCardsToCollection: ((PublicCollection) -> Void)?
    
    var onAddToCollection: ((PublicCollection) -> Void)?
    
    var onDismiss: (() -> Void)?
    
    private let viewModel = PublicCollectionDetailViewModel()
    
    @State private var trayViewModel = BDButtonTrayViewModel()
    
    @State private var showDescription = false
    
    @State private var fetchFailed = false
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PublicCollectionDetailHeaderView(
                    collection: collection,
                    onDescriptionSelected: { self.$showDescription.animation(.easeInOut).wrappedValue.toggle() })
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                
                if showDescription {
                    Text(collection.description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.callout)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }
                
                Divider()
                
                CollectionViewWrapper(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
            }
            
            Color.clear.overlay(BDButtonTrayView(viewModel: trayViewModel).padding(16), alignment: .bottomTrailing)
        }
        .onAppear(perform: setupOnAppear)
        .alert(isPresented: $fetchFailed, content: fetchFailedAlert)
    }
}


extension PublicCollectionDetailView {
    
    func setupOnAppear() {
        setupTrayViewModel()
        setupViewModel()
        fetchCards()
    }
    
    func setupViewModel() {
        let base = CGFloat(140)
        let spacing = CGFloat(40 * trayViewModel.items.count)
        let items = CGFloat(30 * trayViewModel.items.count)
        viewModel.contentInsets.bottom = base + spacing + items
        
        // setup places cards
        let cards = (0..<collection.cardsCount).map { _ in
            PublicCard.placeholder(collectionID: collection.collectionID)
        }
        
        viewModel.cards = cards
        
        DispatchQueue.main.async {
            self.viewModel.updateSnapshot(animated: false)
        }
    }
    
    func setupTrayViewModel() {
        trayViewModel.setDefaultColors()
        trayViewModel.locked = true
        trayViewModel.shouldDisableMainItemWhenExpanded = false
        
        trayViewModel.mainItem = .init(title: "", systemImage: SFSymbol.dismiss) { item in
            self.onDismiss?()
        }
        
        let addToCollections = BDButtonTrayItem(title: "Add To Collections", systemImage: SFSymbol.addCollection) { item in
            self.onAddToCollection?(self.collection)
        }
        
        trayViewModel.items = [addToCollections]
    }
    
    func setTrayMainItemState(isLoading: Bool) {
        trayViewModel.mainItem.animated = isLoading
        trayViewModel.expanded = !isLoading
        trayViewModel.mainItem.title = isLoading ? "Loading Cards..." : ""
    }
    
    func fetchCards() {
        setTrayMainItemState(isLoading: true)
        
        let recordManager = PublicRecordManager.shared
        let collectionID = collection.collectionID
        let desiredFields = [PublicCard.RecordFields.cardID, .native, .translation, .formality]
        
        recordManager.queryCards(withCollectionID: collectionID, desiredFields: desiredFields) { result in
            switch result {
                
            case .success(let records):
                let cards = records.map({ PublicCard(record: $0) })
                self.viewModel.cards = cards
                DispatchQueue.main.async {
                    self.viewModel.updateSnapshot(animated: true)
                    self.setTrayMainItemState(isLoading: false)
                }
                
            case .failure:
                DispatchQueue.main.async {
                    self.fetchFailed = true
                    self.setTrayMainItemState(isLoading: false)
                }
            }
        }
    }
    
    func fetchFailedAlert() -> Alert {
        let title = "Loading Failed"
        let message = "Unable to fetch \(collection.name)'s cards."
        let retry = Alert.Button.default(Text("Retry"), action: fetchCards)
        let dismiss = Alert.Button.default(Text("Dismiss"), action: onDismiss ?? {})
        return Alert(title: Text(title), message: Text(message), primaryButton: dismiss, secondaryButton: retry)
    }
}


struct PublicCollectionDetailHeaderView: View {
    
    var collection: PublicCollection
    
    var onDescriptionSelected: () -> Void = {}
    
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(collection.name).bold()
                Spacer()
                Text("\(collection.primaryLanguage) - \(collection.secondaryLanguage)").font(.footnote)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text("by ").foregroundColor(.secondary)
                Text(collection.authorName)
                Spacer()
                Text(String(quantity: collection.cardsCount, singular: "CARD", plural: "CARDS"))
            }
            .font(.footnote)
            
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(collection.tags, id: \.self) { tag in
                            Text(tag)
                                .frame(minWidth: 30)
                                .font(.footnote)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 8)
                                .foregroundColor(.primary)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(20)
                        }
                    }
                }
                
                Divider().frame(maxHeight: 16)
                
                Button(action: onDescriptionSelected) {
                    Text("description")
                        .font(.footnote)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .foregroundColor(.appAccent)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(20)
                }
            }
            .padding(.top, 4)
        }
    }
}


struct PublicCollectionDetailView_Previews: PreviewProvider {
    static let collection = PublicCollection(
        collectionID: "collectionID", authorID: "authorID",
        authorName: "author name", name: "Collection Name", description: "",
        primaryLanguage: "Korean", secondaryLanguage: "English", tags: [], cardsCount: 9
    )
    static var previews: some View {
        PublicCollectionDetailView(collection: collection)
    }
}
