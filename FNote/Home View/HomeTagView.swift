//
//  HomeTagView.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit
import BDSwiftility


struct HomeTagView: View {
        
    @EnvironmentObject private var appState: AppState
    
    var viewModel: TagCollectionViewModel
    
    @State private var trayViewModel = BDButtonTrayViewModel()
    
    @State private var sheet = BDPresentationItem<Sheet>()
    @State private var selectedTagName = ""
    
    @State private var alert: Alert?
    @State private var showAlert = false
    
    @State private var textFieldModel = BDModalTextFieldModel()
    let noteCardCollectionModel = NoteCardCollectionViewModel()
    
    
    var body: some View {
        NavigationView {
            ZStack {
                CollectionViewWrapper(viewModel: viewModel)
                    .navigationBarTitle("Tags")
                    .edgesIgnoringSafeArea(.all)
                
                Color.clear.overlay(buttonTrayView, alignment: .bottomTrailing)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet.current, content: presentationSheet)
        .alert(isPresented: $showAlert, content: { self.alert! })
        .onAppear(perform: setupOnAppear)
    }
}


// MARK: - Sheet

extension HomeTagView {
    
    enum Sheet: BDPresentationSheetItem {
        case modalTextField
        case noteCard
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .modalTextField:
            return BDModalTextField(viewModel: $textFieldModel)
                .eraseToAnyView()
            
        case .noteCard:
            let action = { self.sheet.dismiss() }
            let label = { Text("Done").bold() }
            let doneNavItem = Button(action: action, label: label)
            return NavigationView {
                CollectionViewWrapper(viewModel: noteCardCollectionModel)
                    .navigationBarTitle(Text(selectedTagName), displayMode: .inline)
                    .navigationBarItems(trailing: doneNavItem)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .eraseToAnyView()
        }
    }
}


// MARK: - On Appear

extension HomeTagView {
    
    func setupOnAppear() {
        setupViewModel()
        setupTrayViewModel()
    }
    
    func setupViewModel() {
        viewModel.sectionContentInsets.bottom = 140
        viewModel.tags = appState.tags
        viewModel.contextMenus = [.rename, .delete]
        viewModel.onTagSelected = handleTagSelected
        viewModel.onContextMenuSelected = handleContextMenuSelected
    }
}


// MARK: - Button Tray

extension HomeTagView {
    
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
        BDButtonTrayItem(title: "", systemImage: "plus") { item in
            self.beginCreateTag()
        }
    }
    
    func createTrayItems() -> [BDButtonTrayItem] {
        let removeUnusedTags = BDButtonTrayItem(title: "Delete Unused Tags", systemImage: "trash") { item in
            self.beginDeleteUnusedTags()
        }
        return [removeUnusedTags]
    }
}


// MARK: - Create Tag

extension HomeTagView {
    
    func beginCreateTag() {
        textFieldModel = .init()
        
        textFieldModel.title = "New Tag"
        textFieldModel.placeholder = "name"
        textFieldModel.prompt = "Name cannot contain comma ,"
        textFieldModel.isFirstResponder = true
        
        textFieldModel.onReturnKey = commitCreateTag
        
        textFieldModel.configure = { textField in
            textField.autocapitalizationType = .none
        }
        
        sheet.present(.modalTextField)
    }
    
    func commitCreateTag() {
        let name = textFieldModel.text.trimmed()
        
        if name.isEmpty {
            textFieldModel.isFirstResponder = false
            sheet.dismiss()
            return
        }
        
        let request = TagCUDRequest(name: name)
        let result = appState.createTag(with: request)
        handleTagCUDResult(result)
    }
}


// MARK: - Rename Tag

extension HomeTagView {
    
    func beginRenameTag(_ tag: Tag) {
        textFieldModel = .init()
        
        textFieldModel.title = "Rename"
        textFieldModel.text = tag.name
        textFieldModel.placeholder = tag.name
        textFieldModel.prompt = "Name cannot contain comma ,"
        
        textFieldModel.onReturnKey = {
            self.commitRenameTag(tag)
        }
        
        textFieldModel.isFirstResponder = true
        sheet.present(.modalTextField)
    }
    
    func commitRenameTag(_ tag: Tag) {
        let name = textFieldModel.text.trimmed()
        
        if name.isEmpty {
            textFieldModel.isFirstResponder = false
            sheet.dismiss()
            return
        }
        
        let request = TagCUDRequest(name: name)
        let result = appState.updateTag(tag, with: request)
        handleTagCUDResult(result)
    }
}


// MARK: - Delete Tag

extension HomeTagView {
    
    func beginDeleteTag(_ tag: Tag) {
        let delete = { self.commitDeleteTag(tag) }
        let cancel = { self.alert = nil }
        alert = Alert.DeleteTag(tag, onCancel: cancel, onDelete: delete)
        showAlert = true
    }
    
    func commitDeleteTag(_ tag: Tag) {
        let result = appState.deleteObject(tag)
        handleTagCUDResult(result)
    }
    
    func beginDeleteUnusedTags() {
        let delete = { self.commitDeleteUnusedTags() }
        let cancel = { self.alert = nil }
        alert = Alert.DeleteUnusedTags(onCancel: cancel, onDelete: delete)
        showAlert = true
    }
    
    func commitDeleteUnusedTags() {
        defer { trayViewModel.expanded = false }
        let result = appState.deleteUnusedTags()
        guard case .deleted(let childContext) = result else { return }
        childContext.quickSave()
        childContext.parent?.quickSave()
        appState.fetchTags()
        viewModel.tags = appState.tags
        viewModel.updateSnapshot(animated: true)
    }
}


// MARK: - Action

extension HomeTagView {
    
    func handleTagSelected(_ tag: Tag) {
        let noteCards = tag.noteCards.sorted(by: { $0.translation < $1.translation})
        noteCardCollectionModel.noteCards = noteCards
        noteCardCollectionModel.cellStyle = .short
        noteCardCollectionModel.contextMenus = [.copyNative]
        
        noteCardCollectionModel.onContextMenuSelected = { menu, noteCard in
            guard menu == .copyNative else { return }
            UIPasteboard.general.string = noteCard.native
        }
        
        selectedTagName = tag.name
        sheet.present(.noteCard)
    }
    
    func handleContextMenuSelected(_ menu: TagCell.ContextMenu, tag: Tag) {
        switch menu {
        case .rename: beginRenameTag(tag)
        case .delete: beginDeleteTag(tag)
        }
    }
    
    func handleTagCUDResult(_ result: ObjectCUDResult<Tag>) {
        switch result {
        case .created(_, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchTags()
            viewModel.tags = appState.tags
            viewModel.updateSnapshot(animated: true)
            textFieldModel.isFirstResponder = false
            sheet.dismiss()
            
        case .updated(_, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchTags()
            viewModel.tags = appState.tags
            viewModel.updateSnapshot(animated: true)
            textFieldModel.isFirstResponder = false
            sheet.dismiss()
            
        case .deleted(let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchTags()
            viewModel.tags = appState.tags
            viewModel.updateSnapshot(animated: true)
            sheet.dismiss()
            
        case .unchanged:
            textFieldModel.isFirstResponder = false
            sheet.dismiss()
            
        case .failed: // TODO: inform user if needed
            textFieldModel.prompt = "Duplicate tag name!"
            textFieldModel.promptColor = .red
        }
    }
}


struct HomeTagView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTagView(viewModel: .init())
    }
}
