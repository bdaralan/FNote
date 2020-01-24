//
//  HomeTagView.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct HomeTagView: View {
    
    var tags: [Tag]
    
    @State private var sheet: Sheet?
    
    @State private var modalTextFieldModel = ModalTextFieldModel()
    
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 16) {
                    ForEach(tags) { tag in
                        TagRow(
                            tag: tag,
                            contextMenus: [.rename, .delete],
                            onContextMenuSelected: self.handleContextMenuSelected
                        )
                            .onTapGesture(perform: { self.handleTagSelected(tag) })
                    }
                }
                .padding()
            }
            .navigationBarTitle("Tags")
            .navigationBarItems(trailing: createTagNavItem)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet, content: presentationSheet)
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
    
    
}


// MARK: - Action

extension HomeTagView {
    
    func handleTagSelected(_ tag: Tag) {
        
    }
    
    func handleContextMenuSelected(_ menu: TagRow.ContextMenu, tag: Tag) {
        
    }
}


struct HomeTagView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTagView(tags: [])
    }
}
