//
//  NoteCardAddTagView.swift
//  FNote
//
//  Created by Dara Beng on 9/27/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardAddTagView: View {
    
    @Binding var viewModel: NoteCardAddTagViewModel
    
    /// A tag object used to create or update tag which passed to `onTagCreate` or `onTagRename`.
    @State private var tagModel = TagViewModel(uuid: "", name: "")
        
    /// A flag used to determine the sheet action.
    @State private var modalTextFieldState = CreateUpdateSheetState.create // default sentinel value
    
    /// A placeholder string for the sheet view.
    @State private var modalTextFieldPlaceholder = ""
    
    /// A prompt string for the sheet view.
    @State private var modalTextFieldPrompt = ""
    
    /// A flag used to present or dismiss the rename or create sheet.
    @State private var showModalTextField = false
    
    
    var body: some View {
        List {
            Section(header: Text("SELECTED TAGS").padding(.top, 20)) {
                ForEach(viewModel.includedTags, id: \.uuid) { tag in
                    self.tagRow(for: tag, showCheckmark: true)
                }
                Text("none")
                    .foregroundColor(.secondary)
                    .hidden(!viewModel.includedTags.isEmpty)
            }
            
            Section(header: Text("TAGS")) {
                ForEach(viewModel.excludedTags, id: \.uuid) { tag in
                    self.tagRow(for: tag, showCheckmark: false)
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
    
    func tagRow(for tag: TagViewModel, showCheckmark: Bool) -> some View {
        Button(action: { self.tagRowSelected(tag) }) {
            HStack {
                Text(tag.name)
                Spacer()
                Image(systemName: "checkmark")
                    .hidden(!showCheckmark)
            }
            .accentColor(.primary)
            .contextMenu {
                Button(action: { self.beginRenameTag(tag) }) {
                    Text("Rename")
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }
    
    func tagRowSelected(_ tag: TagViewModel) {
        if viewModel.isIncludedTag(tag) {
            viewModel.addToExcludedTags(tag, sort: true)
        } else {
            viewModel.addToIncludedTags(tag, sort: true)
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
            onCommit: commit
        )
    }
    
    func beginCreateNewTag() {
        tagModel = TagViewModel()
        modalTextFieldPrompt = "New Tag"
        modalTextFieldPlaceholder = "Tag Name"
        modalTextFieldState = .create
        showModalTextField = true
    }
    
    func commitCreateNewTag() {
        if !tagModel.name.isEmptyOrWhiteSpaces() {
            tagModel.name = tagModel.name.trimmed()
            viewModel.addToIncludedTags(tagModel, sort: true)
        }
        dismissModalTextField()
    }
    
    func beginRenameTag(_ tag: TagViewModel) {
        tagModel = tag
        modalTextFieldPrompt = "Rename Tag"
        modalTextFieldPlaceholder = tag.name
        modalTextFieldState = .update
        showModalTextField = true
    }
    
    func commitRenameTag() {
        if modalTextFieldPlaceholder != tagModel.name, !tagModel.name.isEmptyOrWhiteSpaces() {
            tagModel.name = tagModel.name.trimmed()
            viewModel.updateTag(with: tagModel, sort: true)
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
