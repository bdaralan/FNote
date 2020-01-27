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
        .onAppear(perform: setupOnAppear)
    }
}


// MARK: - Sheet

extension HomeTagView {
    
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

extension HomeTagView {
    
    func setupOnAppear() {
        viewModel.availableTags = appState.tags
        viewModel.sections = [.available]
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
        sheet = nil
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
        sheet = nil
    }
}


// MARK: - Delete Tag

extension HomeTagView {
    
    func beginDeleteTag(_ tag: Tag) {
        
    }
    
    func cancelDeleteTag(_ tag: Tag) {
        
    }
    
    func commitDeleteTag(_ tag: Tag) {
        
    }
}


// MARK: - Action

extension HomeTagView {
    
    func handleTagSelected(_ tag: Tag) {
        
    }
    
    func handleContextMenuSelected(_ menu: TagCell.ContextMenu, tag: Tag) {
        switch menu {
        case .rename: beginRenameTag(tag)
        case .delete: beginDeleteTag(tag)
        }
    }
}


struct HomeTagView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTagView(viewModel: .init())
    }
}
