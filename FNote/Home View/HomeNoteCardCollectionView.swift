//
//  HomeNoteCardCollectionView.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct HomeNoteCardCollectionView: View {
    
    @EnvironmentObject var appState: AppState
    
    var viewModel: NoteCardCollectionCollectionViewModel
        
    @State private var sheet: Sheet?
    @State private var modalTextFieldModel = ModalTextFieldModel()
    
    @State private var collectionToDelete: NoteCardCollection?
    
    
    var body: some View {
        NavigationView {
            CollectionViewWrapper(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
                .navigationBarTitle("Collections", displayMode: .large)
                .navigationBarItems(trailing: createNoteCardCollectionNavItem)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet, content: presentationSheet)
        .alert(item: $collectionToDelete, content: deleteNoteCardCollectionAlert)
        .onAppear(perform: setupOnAppear)
    }
}


// MARK: - Sheet

extension HomeNoteCardCollectionView {
    
    enum Sheet: Identifiable {
        var id: Self { self }
        case modalTextField
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .modalTextField:
            return ModalTextField(viewModel: $modalTextFieldModel)
        }
    }
}


// MARK: - On Appear
extension HomeNoteCardCollectionView {
    
    func setupOnAppear() {
        viewModel.collections = appState.collections
        viewModel.contextMenus = [.rename, .delete]
        viewModel.onCollectionSelected = handleNoteCardCollectionSelected
        viewModel.onContextMenuSelected = handleContextMenuSelected
        
        if let collection = appState.currentCollection {
            viewModel.selectedCollectionIDs = [collection.uuid]
        } else {
            viewModel.selectedCollectionIDs = []
        }
    }
}


// MARK: - Action

extension HomeNoteCardCollectionView {
    
    func handleNoteCardCollectionSelected(_ collection: NoteCardCollection) {
        guard collection !== appState.currentCollection else { return }
        viewModel.clearCellIconImages()
        viewModel.selectedCollectionIDs = [collection.uuid]
        appState.setCurrentCollection(collection)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func handleContextMenuSelected(_ menu: NoteCardCollectionCell.ContextMenu, collection: NoteCardCollection) {
        switch menu {
        case .rename:
            beginRenameNoteCardCollection(collection)
        case .delete:
            beginDeleteNoteCardCollection(collection)
        }
    }
}


// MARK: Create Collection

extension HomeNoteCardCollectionView {
    
    var createNoteCardCollectionNavItem: some View {
        NavigationBarButton(imageName: "plus", action: beginCreateNoteCardCollection)
    }
    
    func beginCreateNoteCardCollection() {
        modalTextFieldModel = .init()
        
        modalTextFieldModel.title = "New Collection"
        modalTextFieldModel.placeholder = "Collection Name"
        modalTextFieldModel.isFirstResponder = true
        
        modalTextFieldModel.onReturnKey = commitCreateNoteCardCollection
        
        sheet = .modalTextField
    }
    
    func commitCreateNoteCardCollection() {
        let name = modalTextFieldModel.text.trimmed()
        
        guard !name.isEmpty else {
            sheet = nil
            return
        }
        
        let request = NoteCardCollectionCUDRequest(name: name)
        let result = appState.createNoteCardCollection(with: request)
        handleNoteCardCollectionCUDResult(result)
    }
}


// MARK: Rename Collection

extension HomeNoteCardCollectionView {
    
    func beginRenameNoteCardCollection(_ collection: NoteCardCollection) {
        modalTextFieldModel = .init()
        
        modalTextFieldModel.title = "Rename"
        modalTextFieldModel.text = collection.name
        modalTextFieldModel.placeholder = collection.name
        modalTextFieldModel.isFirstResponder = true
        
        modalTextFieldModel.onReturnKey = {
            self.commitRenameNoteCardCollection(collection)
        }
        
        sheet = .modalTextField
    }
    
    func commitRenameNoteCardCollection(_ collection: NoteCardCollection) {
        let name = modalTextFieldModel.text.trimmed()
        
        guard !name.isEmpty else {
            modalTextFieldModel.isFirstResponder = false
            sheet = nil
            return
        }
        
        let request = NoteCardCollectionCUDRequest(name: name)
        let result = appState.updateNoteCardCollection(collection, with: request)
        handleNoteCardCollectionCUDResult(result)
    }
}


// MARK: - Delete Collection

extension HomeNoteCardCollectionView {
    
    func deleteNoteCardCollectionAlert(_ collection: NoteCardCollection) -> Alert {
        Alert.DeleteNoteCardCollection(collection, onCancel: cancelDeleteNoteCardCollection, onDelete: commitDeleteNoteCardCollection)
    }
    
    func beginDeleteNoteCardCollection(_ collection: NoteCardCollection) {
        collectionToDelete = collection
    }
    
    func cancelDeleteNoteCardCollection() {
        collectionToDelete = nil
    }
    
    func commitDeleteNoteCardCollection() {
        guard let collection = collectionToDelete else { return }
        let result = appState.deleteObject(collection)
        handleNoteCardCollectionCUDResult(result)
    }
}


// MARK: - CUD Result

extension HomeNoteCardCollectionView {

    func handleNoteCardCollectionCUDResult(_ result: ObjectCUDResult<NoteCardCollection>) {
        switch result {
        case .created(let collection, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchCollections()
            if appState.currentCollection == nil {
                let collection = collection.get(from: appState.parentContext)
                appState.setCurrentCollection(collection)
                viewModel.selectedCollectionIDs = [collection.uuid]
            }
            viewModel.collections = appState.collections
            viewModel.updateSnapshot(animated: true)
            modalTextFieldModel.isFirstResponder = false
            sheet = nil
            
        case .updated(_, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchCollections()
            viewModel.collections = appState.collections
            viewModel.updateSnapshot(animated: true)
            modalTextFieldModel.isFirstResponder = false
            sheet = nil
            
        case .deleted(let childContext):
            if collectionToDelete == appState.currentCollection {
                appState.setCurrentCollection(nil)
                UISelectionFeedbackGenerator().selectionChanged()
            }
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchCollections()
            viewModel.collections = appState.collections
            viewModel.updateSnapshot(animated: true)
            sheet = nil
            
        case .unchanged:
            modalTextFieldModel.isFirstResponder = false
            sheet = nil
            
        case .failed: // TODO: inform user if needed
            modalTextFieldModel.prompt = "Duplicate collection name!"
            modalTextFieldModel.promptColor = .red
        }
    }
}


struct HomeNoteCardCollectionView_Previews: PreviewProvider {
    static let samples = [NoteCardCollection.sample, .sample, .sample]
    static var previews: some View {
        HomeNoteCardCollectionView(viewModel: .init())
    }
}
