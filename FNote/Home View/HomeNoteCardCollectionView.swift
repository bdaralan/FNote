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
    
    @EnvironmentObject private var appState: AppState
    
    @State private var viewModel = NoteCardCollectionCollectionViewModel()
        
    @State private var sheet = BDPresentationItem<Sheet>()
    @State private var textFieldModel = BDModalTextFieldModel()
    
    @State private var alert: Alert?
    @State private var presentAlert = false
    
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
        .sheet(item: $sheet.current, content: presentationSheet)
        .alert(isPresented: $presentAlert, content: { self.alert! })
        .onAppear(perform: setupOnAppear)
    }
}


// MARK: - Sheet

extension HomeNoteCardCollectionView {
    
    enum Sheet: BDPresentationSheetItem {
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
        } else {
            viewModel.selectedCollectionIDs = []
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
        onSelected?(collection)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func handleContextMenuSelected(_ menu: NoteCardCollectionCollectionViewModel.ContextMenu, collection: NoteCardCollection) {
        switch menu {
        case .rename:
            beginRenameNoteCardCollection(collection)
        case .delete:
            beginDeleteNoteCardCollection(collection)
        case .importData:
            break
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
        sheet.present(.modalTextField)
    }
    
    func commitRenameNoteCardCollection(_ collection: NoteCardCollection) {
        let name = textFieldModel.text.trimmed()
        
        if name.isEmpty || name == collection.name {
            textFieldModel.isFirstResponder = false
            sheet.dismiss()
            return
        }
        
        if appState.isDuplicateCollectionName(name) {
            textFieldModel.prompt = "Duplicate collection name!"
            textFieldModel.promptColor = .red
            return
        }
        
        var collectionModifier = ObjectModifier<NoteCardCollection>(.update(collection))
        collectionModifier.name = name
        collectionModifier.save()
        
        appState.fetchCollections()
        viewModel.collections = appState.collections
        viewModel.updateSnapshot(animated: true)
        textFieldModel.isFirstResponder = false
        sheet.dismiss()
    }
}


// MARK: - Delete Collection

extension HomeNoteCardCollectionView {
    
    func beginDeleteNoteCardCollection(_ collection: NoteCardCollection) {
        let cancel = { self.presentAlert = false }
        let delete = { self.commitDeleteNoteCardCollection(collection) }
        alert = Alert.DeleteNoteCardCollection(collection, onCancel: cancel, onDelete: delete)
        presentAlert = true
    }
    
    func commitDeleteNoteCardCollection(_ collection: NoteCardCollection) {
        let collectionID = collection.uuid // keep the ID value before it is deleted
        
        if collectionID == appState.currentCollection?.uuid {
            appState.setCurrentCollection(nil)
            UISelectionFeedbackGenerator().selectionChanged()
        }
        
        let collectionModifier = ObjectModifier<NoteCardCollection>(.update(collection))
        collectionModifier.delete()
        collectionModifier.save()
        
        appState.fetchCollections()
        viewModel.collections = appState.collections
        viewModel.updateSnapshot(animated: true)
        
        presentAlert = false
        
        onDeleted?(collectionID)
    }
}


struct HomeNoteCardCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        HomeNoteCardCollectionView()
    }
}
