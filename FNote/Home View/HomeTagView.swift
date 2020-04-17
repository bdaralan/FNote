//
//  HomeTagView.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit


struct HomeTagView: View {
    
    @EnvironmentObject var appState: AppState
    
    var viewModel: TagCollectionViewModel
    
    @State private var trayViewModel = BDButtonTrayViewModel()
    
    @State private var sheet: Sheet?
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
                
                Color.clear.overlay(
                    BDButtonTrayView(viewModel: trayViewModel).padding(16),
                    alignment: .bottomTrailing
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet, content: presentationSheet)
        .alert(isPresented: $showAlert, content: { self.alert! })
        .onAppear(perform: setupOnAppear)
    }
}


// MARK: - Sheet

extension HomeTagView {
    
    enum Sheet: Identifiable {
        var id: Self { self }
        case modalTextField
        case noteCard
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .modalTextField:
            return BDModalTextField(viewModel: $textFieldModel)
                .eraseToAnyView()
            
        case .noteCard:
            let action = { self.sheet = nil }
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
    
    func setupTrayViewModel() {
        trayViewModel.buttonSystemImage = "plus"
        
        trayViewModel.action = {
            self.beginCreateTag()
        }
        
        let removeUnusedTags = BDButtonTrayItem(title: "Delete Unused Tags", systemImage: "trash") { item in
            self.beginDeleteUnusedTags()
        }
        
        trayViewModel.items = [removeUnusedTags]
    }
}


// MARK: - Create Tag

extension HomeTagView {
    
    func beginCreateTag() {
        textFieldModel = .init()
        
        textFieldModel.title = "New Tag"
        textFieldModel.placeholder = "name"
        textFieldModel.isFirstResponder = true
        
        textFieldModel.onReturnKey = commitCreateTag
        
        textFieldModel.configure = { textField in
            textField.autocapitalizationType = .none
        }
        
        sheet = .modalTextField
    }
    
    func commitCreateTag() {
        let name = textFieldModel.text.trimmed()
        
        if name.isEmpty {
            textFieldModel.isFirstResponder = false
            sheet = nil
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
        textFieldModel.isFirstResponder = true
        
        textFieldModel.onReturnKey = {
            self.commitRenameTag(tag)
        }
        
        sheet = .modalTextField
    }
    
    func commitRenameTag(_ tag: Tag) {
        let name = textFieldModel.text.trimmed()
        
        if name.isEmpty {
            textFieldModel.isFirstResponder = false
            sheet = nil
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
        sheet = .noteCard
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
            sheet = nil
            
        case .updated(_, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchTags()
            viewModel.tags = appState.tags
            viewModel.updateSnapshot(animated: true)
            textFieldModel.isFirstResponder = false
            sheet = nil
            
        case .deleted(let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchTags()
            viewModel.tags = appState.tags
            viewModel.updateSnapshot(animated: true)
            sheet = nil
            
        case .unchanged:
            textFieldModel.isFirstResponder = false
            sheet = nil
            
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
