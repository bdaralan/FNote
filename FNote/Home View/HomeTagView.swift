//
//  HomeTagView.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct HomeTagView: View {
    
    @EnvironmentObject var appState: AppState
    
    var viewModel: TagCollectionViewModel
    
    @State private var sheet: Sheet?
    
    @State private var modalTextFieldModel = ModalTextFieldModel()
    let noteCardCollectionModel = NoteCardCollectionViewModel()
    
    @State private var tagToDelete: Tag?
    
    
    var body: some View {
        NavigationView {
            CollectionViewWrapper(viewModel: viewModel)
                .navigationBarTitle("Tags")
                .navigationBarItems(trailing: createTagNavItem)
                .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet, content: presentationSheet)
        .alert(item: $tagToDelete, content: deleteTagAlert)
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
            return ModalTextField(viewModel: $modalTextFieldModel)
                .eraseToAnyView()
            
        case .noteCard:
            let action = { self.sheet = nil }
            let label = { Text("Done").bold() }
            let doneNavItem = Button(action: action, label: label)
            return NavigationView {
                CollectionViewWrapper(viewModel: noteCardCollectionModel)
                    .navigationBarTitle("Cards", displayMode: .inline)
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
        viewModel.tags = appState.tags
        viewModel.contextMenus = [.rename, .delete]
        viewModel.onTagSelected = handleTagSelected
        viewModel.onContextMenuSelected = handleContextMenuSelected
    }
}


// MARK: - Create Tag

extension HomeTagView {
    
    var createTagNavItem: some View {
        NavigationBarButton(imageName: "plus", action: beginCreateTag)
    }
    
    func beginCreateTag() {
        modalTextFieldModel = .init()
        
        modalTextFieldModel.title = "New Tag"
        modalTextFieldModel.placeholder = "Tag Name"
        modalTextFieldModel.isFirstResponder = true
        
        modalTextFieldModel.onCommit = commitCreateTag
        
        sheet = .modalTextField
    }
    
    func commitCreateTag() {
        let name = modalTextFieldModel.text.trimmed()
        
        if name.isEmpty {
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
        modalTextFieldModel = .init()
        
        modalTextFieldModel.title = "Rename"
        modalTextFieldModel.text = tag.name
        modalTextFieldModel.placeholder = tag.name
        modalTextFieldModel.isFirstResponder = true
        
        modalTextFieldModel.onCommit = {
            self.commitRenameTag(tag)
        }
        
        sheet = .modalTextField
    }
    
    func commitRenameTag(_ tag: Tag) {
        let name = modalTextFieldModel.text.trimmed()
        
        if name.isEmpty {
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
    
    func deleteTagAlert(_ tag: Tag) -> Alert {
        Alert.DeleteTag(tag, onCancel: cancelDeleteTag, onDelete: commitDeleteTag)
    }
    
    func beginDeleteTag(_ tag: Tag) {
        tagToDelete = tag
    }
    
    func cancelDeleteTag() {
        tagToDelete = nil
    }
    
    func commitDeleteTag() {
        guard let tag = tagToDelete else { return }
        let result = appState.deleteObject(tag)
        handleTagCUDResult(result)
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
            sheet = nil
            
        case .updated(_, let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchTags()
            viewModel.tags = appState.tags
            viewModel.updateSnapshot(animated: true)
            sheet = nil
            
        case .deleted(let childContext):
            childContext.quickSave()
            childContext.parent?.quickSave()
            appState.fetchTags()
            viewModel.tags = appState.tags
            viewModel.updateSnapshot(animated: true)
            sheet = nil
            
        case .unchanged:
            sheet = nil
            
        case .failed: // TODO: inform user if needed
            modalTextFieldModel.prompt = "Duplicate tag name!"
            modalTextFieldModel.promptColor = .red
        }
    }
}


struct HomeTagView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTagView(viewModel: .init())
    }
}
