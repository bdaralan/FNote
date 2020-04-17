//
//  HomeNoteCardCollectionView.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit


struct HomeNoteCardCollectionView: View {
    
    @EnvironmentObject var appState: AppState
    
    @State private var viewModel = NoteCardCollectionCollectionViewModel()
        
    @State private var sheet: Sheet?
    @State private var textFieldModel = BDModalTextFieldModel()
    
    @State private var collectionToDelete: NoteCardCollection?
    @State private var collectionIDToDelete: String?
    
    var onSelected: ((NoteCardCollection) -> Void)?
    var onRenamed: ((NoteCardCollection) -> Void)?
    var onDeleted: ((String) -> Void)?
    var onDone: (() -> Void)?
    
    
    var body: some View {
        NavigationView {
            CollectionViewWrapper(viewModel: viewModel)
                .navigationBarTitle("Collections", displayMode: .inline)
                .navigationBarItems(trailing: doneNavItem)
                .edgesIgnoringSafeArea(.all)
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
            return BDModalTextField(viewModel: $textFieldModel)
        }
    }
}


// MARK: - On Appear

extension HomeNoteCardCollectionView {
    
    func setupOnAppear() {
        appState.fetchCollections()
        viewModel.collections = appState.collections
        viewModel.contextMenus = [.rename, .delete]
        viewModel.onCollectionSelected = handleNoteCardCollectionSelected
        viewModel.onContextMenuSelected = { menu, collection in
            self.handleContextMenuSelected(menu, collection: collection)
        }
        
        if let collection = appState.currentCollection {
            viewModel.selectedCollectionIDs = [collection.uuid]
            viewModel.ignoreSelectionCollectionIDs = [collection.uuid]
        } else {
            viewModel.selectedCollectionIDs = []
            viewModel.ignoreSelectionCollectionIDs = []
        }
    }
}


// MARK: - Action

extension HomeNoteCardCollectionView {
    
    var doneNavItem: some View {
        Button(action: onDone ?? {}) {
            Text("Done").bold()
        }
    }
    
    func handleNoteCardCollectionSelected(_ collection: NoteCardCollection) {
        viewModel.clearCellIconImages()
        viewModel.selectedCollectionIDs = [collection.uuid]
        viewModel.ignoreSelectionCollectionIDs = [collection.uuid]
        appState.setCurrentCollection(collection)
        UISelectionFeedbackGenerator().selectionChanged()
        onSelected?(collection)
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


// MARK: Rename Collection

extension HomeNoteCardCollectionView {
    
    func beginRenameNoteCardCollection(_ collection: NoteCardCollection) {
        textFieldModel = .init()
        
        textFieldModel.title = "Rename"
        textFieldModel.text = collection.name
        textFieldModel.placeholder = collection.name
        textFieldModel.prompt = "Name cannot contain comma ,"
        
        textFieldModel.onReturnKey = {
            self.commitRenameNoteCardCollection(collection)
        }
        
        textFieldModel.isFirstResponder = true
        sheet = .modalTextField
    }
    
    func commitRenameNoteCardCollection(_ collection: NoteCardCollection) {
        let name = textFieldModel.text.trimmed()
        
        guard !name.isEmpty else {
            textFieldModel.isFirstResponder = false
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
        let cancel = cancelDeleteNoteCardCollection
        let delete = { self.commitDeleteNoteCardCollection(collection) }
        return Alert.DeleteNoteCardCollection(collection, onCancel: cancel, onDelete: delete)
    }
    
    func beginDeleteNoteCardCollection(_ collection: NoteCardCollection) {
        collectionToDelete = collection
        collectionIDToDelete = collection.uuid
    }
    
    func cancelDeleteNoteCardCollection() {
        collectionToDelete = nil
        collectionIDToDelete = nil
    }
    
    func commitDeleteNoteCardCollection(_ collection: NoteCardCollection) {
        let result = appState.deleteObject(collection)
        handleNoteCardCollectionCUDResult(result)
    }
}


// MARK: - CUD Result

extension HomeNoteCardCollectionView {

    func handleNoteCardCollectionCUDResult(_ result: ObjectCUDResult<NoteCardCollection>) {
        switch result {
        case .created:
            fatalError("🧨 unexpected use case for handleNoteCardCollectionCUDResult 🧨")
            
        case .updated(_, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchCollections()
            viewModel.collections = appState.collections
            viewModel.updateSnapshot(animated: true)
            textFieldModel.isFirstResponder = false
            sheet = nil
            
        case .deleted(let childContext):
            guard let collectionID = collectionIDToDelete else {
                fatalError("🧨 attempt to delete collection without keeping a reference of its ID 🧨")
            }
            
            if collectionID == appState.currentCollection?.uuid {
                appState.setCurrentCollection(nil)
                UISelectionFeedbackGenerator().selectionChanged()
            }
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchCollections()
            viewModel.collections = appState.collections
            viewModel.updateSnapshot(animated: true)

            collectionToDelete = nil
            collectionIDToDelete = nil
            onDeleted?(collectionID)
            
        case .unchanged:
            textFieldModel.isFirstResponder = false
            sheet = nil
            
        case .failed: // TODO: inform user if needed
            textFieldModel.prompt = "Duplicate collection name!"
            textFieldModel.promptColor = .orange
        }
    }
}


struct HomeNoteCardCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        HomeNoteCardCollectionView()
    }
}
