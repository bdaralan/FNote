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
        
    /// A flag used to determine the sheet action.
    @State private var sheetState: CreateUpdateSheetState?
    
    /// A flag used to present or dismiss the rename or create sheet.
    @State private var showSheet = false
    
    /// A tag object used to create or update tag which passed to `onTagCreate` or `onTagRename`.
    @State private var sheetTag = TagViewModel(uuid: "", name: "")
    
    /// A placeholder string for the sheet view.
    @State private var sheetTagPlaceholder = ""
    
    /// A prompt string for the sheet view.
    @State private var sheetTagPrompt = ""
    
    
    var body: some View {
        List {
            Section(header: Text("SELECTED TAGS").padding(.top, 20)) {
                ForEach(viewModel.includedTags, id: \.uuid) { tag in
                    self.tagRow(for: tag)
                }
                if viewModel.includedTags.isEmpty {
                    Text("none").foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("TAGS")) {
                ForEach(viewModel.excludedTags, id: \.uuid) { tag in
                    self.tagRow(for: tag)
                }
                if viewModel.excludedTags.isEmpty {
                    Text("none").foregroundColor(.secondary)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Note Card Tags", displayMode: .inline)
        .navigationBarItems(trailing: createNewTagNavItem)
        .sheet(isPresented: $showSheet, onDismiss: dismissPresentationSheet, content: modalTextFieldSheet)
    }
}


extension NoteCardAddTagView {
    
    func tagRow(for tag: TagViewModel) -> some View {
        Button(action: { self.tagRowSelected(tag) }) {
            HStack {
                Text(tag.name)
                Spacer()
                Image(systemName: "checkmark")
                    .opacity(viewModel.includedTags.contains(where: { $0.uuid == tag.uuid }) ? 1 : 0)
            }
        }
        .buttonStyle(PlainButtonStyle())
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
    
    func modalTextFieldSheet() -> some View {
        ModalTextField(
            isActive: $showSheet,
            text: $sheetTag.name,
            prompt: sheetTagPrompt,
            placeholder: sheetTagPlaceholder,
            onCommit: modalTextFieldCommitNamingTag
        )
    }
    
    func modalTextFieldCommitNamingTag() {
        switch sheetState {
        case .update: commitRenameTag()
        case .create: commitCreateNewTag()
        case nil: fatalError("commit naming without setting presetationSheetState")
        }
    }
    
    func beginCreateNewTag() {
        sheetTag = TagViewModel()
        sheetTagPrompt = "New Tag"
        sheetTagPlaceholder = "Tag Name"
        sheetState = .create
        showSheet = true
    }
    
    func commitCreateNewTag() {
        if !sheetTag.name.isEmptyOrWhiteSpaces() {
            sheetTag.name = sheetTag.name.trimmed()
            viewModel.addToIncludedTags(sheetTag, sort: true)
        }
        dismissPresentationSheet()
    }
    
    func beginRenameTag(_ tag: TagViewModel) {
        sheetTag = tag
        sheetTagPrompt = "Rename Tag"
        sheetTagPlaceholder = tag.name
        sheetState = .update
        showSheet = true
    }
    
    func commitRenameTag() {
        print(sheetTag)
        if sheetTagPlaceholder != sheetTag.name, !sheetTag.name.isEmptyOrWhiteSpaces() {
            sheetTag.name = sheetTag.name.trimmed()
            viewModel.updateTag(with: sheetTag, sort: true)
        }
        dismissPresentationSheet()
    }
    
    func dismissPresentationSheet() {
        sheetState = nil
        showSheet = false
    }
}


struct NoteCardAddTagView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardAddTagView(viewModel: .constant(.init()))
    }
}
