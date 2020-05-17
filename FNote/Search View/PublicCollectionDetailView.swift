//
//  PublicCollectionDetailView.swift
//  FNote
//
//  Created by Dara Beng on 5/2/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit
import CoreData


struct PublicCollectionDetailView: View {
    
    var collection: PublicCollection
    
    /// A context used to save public records to user's collections.
    var context: NSManagedObjectContext
    
    var onAddCardsToCollection: ((PublicCollection) -> Void)?
    
    var onAddToCollection: ((PublicCollection) -> Void)?
    
    var onDismiss: (() -> Void)?
    
    private let viewModel = PublicCollectionDetailViewModel()
    
    @State private var trayViewModel = BDButtonTrayViewModel()
    
    @State private var showDescription = false
    
    @State private var isPreparingToSave = false // flag to prevent multiple triggers
    
    @State private var alert: Alert?
    @State private var presentAlert = false
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PublicCollectionDetailHeaderView(collection: collection)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                
                Divider()
                
                CollectionViewWrapper(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
            }
            
            Color.clear.overlay(BDButtonTrayView(viewModel: trayViewModel).padding(16), alignment: .bottomTrailing)
        }
        .onAppear(perform: setupOnAppear)
        .alert(isPresented: $presentAlert, content: { self.alert! })
    }
}


// MARK: - Setup

extension PublicCollectionDetailView {
    
    func setupOnAppear() {
        setupTrayViewModel()
        setupViewModel()
        fetchCards()
    }
    
    func setupViewModel() {
        let trayMaxItems = 1
        let spacing = CGFloat(40 * trayMaxItems)
        let items = CGFloat(30 * trayMaxItems)
        viewModel.contentInsets.bottom = 140 + spacing + items
        
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
        
        trayViewModel.mainItem = .init(title: "", image: .system(SFSymbol.dismiss)) { item in
            self.onDismiss?()
        }
        
        setAddToCollectionTrayItem()
    }
    
    func setAddToCollectionTrayItem() {
        let add = BDButtonTrayItem(title: "Add To Collections", image: .system(SFSymbol.addCollection)) { item in
            self.beginSaveCollection()
        }
        trayViewModel.items = [add]
        trayViewModel.expanded = true
    }
    
    func setLoadingTrayItem(title: String) {
        let fetching = BDButtonTrayItem(title: title, image: .system(SFSymbol.loading), action: { _ in })
        fetching.animation = .rotation()
        fetching.disabled = true
        fetching.inactiveColor = .appAccent
        trayViewModel.items = [fetching]
        trayViewModel.expanded = true
    }
    
    func fetchCards() {
        setLoadingTrayItem(title: "Loading Cards...")
        
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
                    self.setAddToCollectionTrayItem()
                }
                
            case .failure:
                DispatchQueue.main.async {
                    self.trayViewModel.items = []
                    self.trayViewModel.expanded = false
                    self.alert = self.fetchCardsFailedAlert
                    self.presentAlert = true
                }
            }
        }
    }
}


// MARK: - Save Collection

extension PublicCollectionDetailView {
    
    func beginSaveCollection() {
        guard isPreparingToSave == false else { return }
        
        isPreparingToSave = true
        setLoadingTrayItem(title: "Preparing Cards...")
        
        let importContext = context.newChildContext()
        let generator = ObjectGenerator(context: importContext)
        generator.importPublicCollection(collection) { collection in
            DispatchQueue.main.async {
                if collection == nil {
                    self.setAddToCollectionTrayItem()
                    self.isPreparingToSave = false
                    self.alert = self.prepareCardsFailedAlert
                    self.presentAlert = true
                } else {
                    self.isPreparingToSave = false
                    self.confirmSaveCollection(context: importContext)
                }
            }
        }
    }
    
    func confirmSaveCollection(context: ManagedObjectChildContext) {
        let add = BDButtonTrayItem(title: "Ready To Add", image: .system(SFSymbol.addCollection)) { item in
            guard item.disabled == false else { return }
            item.disabled = true
            item.animation = nil
            item.inactiveColor = .green
            item.title = "Added"
            
            context.quickSave()
            context.parent?.quickSave()
        }
        
        add.animation = .pulse()
        
        trayViewModel.items = [add]
    }
}


// MARK: - Alert

extension PublicCollectionDetailView {
    
    var fetchCardsFailedAlert: Alert {
        let title = "Loading Failed"
        let message = "Unable to fetch \(collection.name)'s cards."
        let retry = Alert.Button.default(Text("Retry"), action: fetchCards)
        let dismiss = Alert.Button.default(Text("Dismiss"), action: onDismiss ?? {})
        return Alert(title: Text(title), message: Text(message), primaryButton: dismiss, secondaryButton: retry)
    }
    
    var prepareCardsFailedAlert: Alert {
        let title = "Preparing Failed"
        let message = "Unable to prepare \(collection.name)'s cards."
        let retry = Alert.Button.default(Text("Retry"), action: beginSaveCollection)
        let dismiss = Alert.Button.default(Text("Cancel"), action: setupTrayViewModel)
        return Alert(title: Text(title), message: Text(message), primaryButton: dismiss, secondaryButton: retry)
    }
}


struct PublicCollectionDetailView_Previews: PreviewProvider {
    static let collection = PublicCollectionDetailHeaderView_Previews.collection
    static var previews: some View {
        PublicCollectionDetailView(collection: collection, context: .sample)
    }
}
