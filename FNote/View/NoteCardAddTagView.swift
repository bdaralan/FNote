//
//  NoteCardAddTagView.swift
//  FNote
//
//  Created by Dara Beng on 9/27/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardAddTagView: View {
    
    @EnvironmentObject var tagDataSource: TagDataSource
    
    @Binding var viewModel: NoteCardAddTagViewModel
    
    /// A tag object used to create or update tag which passed to `onTagCreate` or `onTagRename`.
    @State private var tagModel = TagViewModel(uuid: "", name: "")
        
    /// A flag used to determine the sheet action.
    @State private var modalTextFieldState = CreateUpdateSheetState.create // default sentinel value
    
    /// A placeholder string for the sheet view.
    @State private var modalTextFieldPlaceholder = ""
    
    /// A prompt string for the sheet view.
    @State private var modalTextFieldPrompt = ""
    
    /// A description used to describe error.
    @State private var modalTextFieldDescription = ""
    
    /// A flag used to present or dismiss the rename or create sheet.
    @State private var showModalTextField = false
    
    
    var body: some View {
        List {
            Section(header: Text("SELECTED TAGS").padding(.top, 20)) {
                ForEach(viewModel.includedTags, id: \.uuid) { tag in
                    self.tagRow(for: tag)
                }
                Text("none")
                    .foregroundColor(.secondary)
                    .hidden(!viewModel.includedTags.isEmpty)
            }
            
            Section(header: Text("TAGS")) {
                ForEach(viewModel.excludedTags, id: \.uuid) { tag in
                    self.tagRow(for: tag)
                }
                Text("none")
                    .foregroundColor(.secondary)
                    .hidden(!viewModel.excludedTags.isEmpty)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Note Card Tags", displayMode: .inline)
        .navigationBarItems(trailing: createNewTagNavItem)
        .sheet(isPresented: $showModalTextField, onDismiss: dismissModalTextField, content: modalTextField)
    }
}


extension NoteCardAddTagView {
    
    func tagRow(for tag: TagViewModel) -> some View {
        Button(action: { self.tagRowSelected(tag) }) {
            Text(tag.name)
                .accentColor(.primary)
                .contextMenu(menuItems: { renameTagContextMenuItem(for: tag) })
        }
    }
    
    func tagRowSelected(_ tag: TagViewModel) {
        if viewModel.isIncludedTag(tag) {
            viewModel.addToExcludedTags(tag)
        } else {
            viewModel.addToIncludedTags(tag)
        }
    }
    
    func renameTagContextMenuItem(for tag: TagViewModel) -> some View {
        Button(action: { self.beginRenameTag(tag) }) {
            Text("Rename")
            Image(systemName: "square.and.pencil")
        }
    }
}


extension NoteCardAddTagView {
    
    var createNewTagNavItem: some View {
        Button(action: beginCreateNewTag) {
            Image(systemName: "plus")
                .imageScale(.large)
        }
    }
    
    func modalTextField() -> some View {
        let commit: () -> Void
        
        switch modalTextFieldState {
        case .create: commit = commitCreateNewTag
        case .update: commit = commitRenameTag
        }
        
        return ModalTextField(
            isActive: $showModalTextField,
            text: $tagModel.name,
            prompt: modalTextFieldPrompt,
            placeholder: modalTextFieldPlaceholder,
            description: modalTextFieldDescription,
            descriptionColor: .red,
            onCommit: commit
        )
    }
    
    func beginCreateNewTag() {
        tagModel = TagViewModel()
        modalTextFieldState = .create
        modalTextFieldPrompt = "New Tag"
        modalTextFieldPlaceholder = "Tag Name"
        modalTextFieldDescription = ""
        showModalTextField = true
    }
    
    func commitCreateNewTag() {
        // if tag exists, show cannot create message
        if tagDataSource.isTagNameExisted(tagModel.name, in: tagDataSource.updateContext) {
            modalTextFieldDescription = "Tag name '\(tagModel.name)' already exists"
            return
        }
        
        // create if it is not an empty whitespaces
        if !tagModel.name.isEmptyOrWhiteSpaces() {
            tagModel.name = tagModel.name.trimmed()
            viewModel.addToIncludedTags(tagModel)
        }
        dismissModalTextField()
    }
    
    func beginRenameTag(_ tag: TagViewModel) {
        tagModel = tag
        modalTextFieldState = .update
        modalTextFieldPrompt = "Rename Tag"
        modalTextFieldPlaceholder = tag.name
        modalTextFieldDescription = ""
        showModalTextField = true
    }
    
    func commitRenameTag() {
        // just dismiss if the name is the same
        // note: placeholder was set to tag's current name in begin rename method
        if modalTextFieldPlaceholder == tagModel.name {
            dismissModalTextField()
            return
        }
        
        // if tag name exists, show tag name exists message
        if tagDataSource.isTagNameExisted(tagModel.name, in: tagDataSource.updateContext) {
            modalTextFieldDescription = "Tag name '\(tagModel.name)' already exists"
            return
        }
        
        // rename if it is not an empty whitespaces
        if !tagModel.name.isEmptyOrWhiteSpaces() {
            tagModel.name = tagModel.name.trimmed()
            viewModel.updateTag(with: tagModel)
        }
        dismissModalTextField()
    }
    
    func dismissModalTextField() {
        showModalTextField = false
    }
}


struct NoteCardAddTagView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardAddTagView(viewModel: .constant(.init()))
    }
}
