//
//  NoteCardAddTagView.swift
//  FNote
//
//  Created by Dara Beng on 9/27/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardAddTagView: View {
    
    @Binding var addedTags: [TagViewModel]
    
    @Binding var addableTags: [TagViewModel]
    
    var onTagAdd: ((TagViewModel) -> Void)?
    
    var onTagRemove: ((TagViewModel) -> Void)?
    
    var onTagCreate: ((TagViewModel) -> Void)?
    
    var onTagRename: ((TagViewModel) -> Void)?
    
    @State private var sheetState: CreateUpdateSheetState?
    
    @State private var tagToCreate = TagViewModel(uuid: "", name: "") // sentinel value
    
    @State private var tagToRename = TagViewModel(uuid: "", name: "") // sentinel value
    
    @State private var tagToRenameCurrentName = "" // hold current name of the tag to rename
    
    
    var body: some View {
        List {
            Section(header: Text("SELECTED TAGS").padding(.top, 20)) {
                ForEach(addedTags) { tag in
                    self.tagRow(for: tag)
                }
                if addedTags.isEmpty {
                    Text("None").foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("TAGS")) {
                ForEach(addableTags) { tag in
                    self.tagRow(for: tag)
                }
                if addableTags.isEmpty {
                    Text("None").foregroundColor(.secondary)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Tags")
        .navigationBarItems(leading: NavigationBarBackButton(), trailing: createNewTagNavItem)
        .sheet(item: $sheetState, onDismiss: dismissPresentationSheet, content: presentationSheet)
    }
}


extension NoteCardAddTagView {
    
    func tagRow(for tag: TagViewModel) -> some View {
        Button(action: { self.tagRowSelected(tag) }) {
            HStack {
                Text(tag.name)
                Spacer()
                Image(systemName: "checkmark")
                    .hidden(!addedTags.contains(tag))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func tagRowSelected(_ tag: TagViewModel) {
        let shouldAddTagToNoteCard = addableTags.contains(tag)
        if shouldAddTagToNoteCard {
            onTagAdd?(tag)
        } else {
            onTagRemove?(tag)
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
    
    func presentationSheet(_ state: CreateUpdateSheetState) -> some View {
        switch sheetState {
        case .create: return createNewTagModalTextField.eraseToAnyView()
        case .update: return renameTagModalTextField.eraseToAnyView()
        case nil: return EmptyView().eraseToAnyView()
        }
    }
    
    var createNewTagModalTextField: some View {
        ModalTextField(
            isActive: .constant(sheetState == .create),
            text: $tagToCreate.name,
            prompt: "Create New Tag",
            placeholder: "Tag Name",
            onCommit: commitCreateNewTag
        )
    }
    
    var renameTagModalTextField: some View {
        ModalTextField(
            isActive: .constant(sheetState == .update),
            text: $tagToRename.name,
            prompt: "Rename Tag",
            placeholder: tagToRenameCurrentName,
            onCommit: commitRenameTag
        )
    }
    
    func beginCreateNewTag() {
        tagToCreate.name = ""
        sheetState = .create
    }
    
    func commitCreateNewTag() {
        sheetState = nil
        onTagCreate?(tagToCreate)
    }
    
    func beginRenameTag() {
        tagToRenameCurrentName = tagToRename.name
        sheetState = .update
    }
    
    func commitRenameTag() {
        sheetState = nil
        onTagRename?(tagToRename)
    }
    
    func dismissPresentationSheet() {
        sheetState = nil
    }
}


struct NoteCardAddTagView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardAddTagView(addedTags: .constant([]), addableTags: .constant([]))
    }
}
