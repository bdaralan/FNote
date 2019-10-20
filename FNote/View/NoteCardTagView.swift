//
//  NoteCardTagView.swift
//  FNote
//
//  Created by Dara Beng on 9/27/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardTagView: View {
    
    @EnvironmentObject var tagDataSource: TagDataSource
    
    @ObservedObject var noteCard: NoteCard
        
    /// A flag used to determine the sheet action.
    @State private var modalTextFieldState = CreateUpdateSheetState.create // default sentinel value
    
    /// A text for the sheet view.
    @State private var modalTextFieldText = ""
    
    /// A placeholder string for the sheet view.
    @State private var modalTextFieldPlaceholder = ""
    
    /// A prompt string for the sheet view.
    @State private var modalTextFieldPrompt = ""
    
    /// A description used to describe error.
    @State private var modalTextFieldDescription = ""
    
    /// A flag used to present or dismiss the rename or create sheet.
    @State private var showModalTextField = false
    
    /// An action to perform when the done button is tapped.
    var onDone: (() -> Void)?
    
    var includedTags: [Tag] {
        let allTags = tagDataSource.fetchedResult.fetchedObjects ?? []
        return allTags.filter { tag in
            self.noteCard.tags.contains(where: { $0.uuid == tag.uuid })
        }
    }
    
    var excludedTags: [Tag] {
        let allTags = tagDataSource.fetchedResult.fetchedObjects ?? []
        return allTags.filter { tag in
            !self.noteCard.tags.contains(where: { $0.uuid == tag.uuid })
        }
    }
    
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("SELECTED TAGS").padding(.top, 20)) {
                    ForEach(includedTags, id: \.uuid) { tag in
                        self.tagRow(for: tag)
                    }
                    Text("none")
                        .foregroundColor(.secondary)
                        .hidden(!noteCard.tags.isEmpty)
                }
                
                Section(header: Text("TAGS")) {
                    ForEach(excludedTags, id: \.uuid) { tag in
                        self.tagRow(for: tag)
                    }
                    Text("none")
                        .foregroundColor(.secondary)
                        .hidden(!excludedTags.isEmpty)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Tags", displayMode: .inline)
            .navigationBarItems(leading: doneNavItem, trailing: createNewTagNavItem)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showModalTextField, onDismiss: dismissModalTextField, content: modalTextField)
    }
}


extension NoteCardTagView {
    
    func tagRow(for tag: Tag) -> some View {
        Button(action: { self.tagRowSelected(tag) }) {
            Text(tag.name)
                .accentColor(.primary)
                .contextMenu(menuItems: { renameTagContextMenuItem(for: tag) })
        }
    }
    
    func tagRowSelected(_ tag: Tag) {
        if let tag = noteCard.tags.first(where: { $0.uuid == tag.uuid }) {
            noteCard.tags.remove(tag)
        
        } else if let tag = tagDataSource.fetchedResult.fetchedObjects?.first(where: { $0.uuid == tag.uuid }) {
            let tagToAdd = tag.get(from: noteCard.managedObjectContext!)
            noteCard.tags.insert(tagToAdd)
        }
    }
    
    func renameTagContextMenuItem(for tag: Tag) -> some View {
        Button(action: { self.beginRenameTag(tag) }) {
            Text("Rename")
            Image(systemName: "square.and.pencil")
        }
    }
}


extension NoteCardTagView {
    
    var createNewTagNavItem: some View {
        Button(action: beginCreateNewTag) {
            Image(systemName: "plus")
                .imageScale(.large)
        }
    }
    
    var doneNavItem: some View {
        Button(action: onDone ?? {}) {
            Text("Done")
        }
        .hidden(onDone == nil)
    }
    
    func modalTextField() -> some View {
        let commit: () -> Void
        
        switch modalTextFieldState {
        case .create: commit = commitCreateNewTag
        case .update: commit = commitRenameTag
        }
        
        return ModalTextField(
            isActive: $showModalTextField,
            text: $modalTextFieldText,
            prompt: modalTextFieldPrompt,
            placeholder: modalTextFieldPlaceholder,
            description: modalTextFieldDescription,
            descriptionColor: .red,
            onCommit: commit
        )
    }
    
    func beginCreateNewTag() {
        modalTextFieldState = .create
        modalTextFieldPrompt = "New Tag"
        modalTextFieldPlaceholder = "Tag Name"
        modalTextFieldDescription = ""
        showModalTextField = true
    }
    
    func commitCreateNewTag() {
        let tagName = modalTextFieldText.trimmed()
        
        // if tag exists, show cannot create message
        if tagDataSource.isTagNameExisted(tagName, in: tagDataSource.createContext) {
            modalTextFieldDescription = "Tag name '\(tagName)' already exists"
            return
        }
        
        // create if it is not an empty whitespaces
        if !tagName.isEmptyOrWhiteSpaces() {
            tagDataSource.prepareNewObject()
            
            let newTag = tagDataSource.newObject!
            newTag.name = tagName
            tagDataSource.saveCreateContext()
            
            let newTagToAdd = newTag.get(from: noteCard.managedObjectContext!)
            noteCard.tags.insert(newTagToAdd)
            
            tagDataSource.discardNewObject()
        }
        
        dismissModalTextField()
    }
    
    func beginRenameTag(_ tag: Tag) {
        tagDataSource.setUpdateObject(tag)
        modalTextFieldText = tag.name
        modalTextFieldPlaceholder = tag.name
        modalTextFieldPrompt = "Rename Tag"
        modalTextFieldDescription = ""
        modalTextFieldState = .update
        showModalTextField = true
    }
    
    func commitRenameTag() {
        guard let tag = tagDataSource.updateObject else { return }
        let tagNewName = modalTextFieldText.trimmed()
        
        // just dismiss if the name is the same
        // note: placeholder was set to tag's current name in begin rename method
        if tagNewName == tag.name {
            dismissModalTextField()
            return
        }
        
        // if tag name exists, show tag name exists message
        if tagDataSource.isTagNameExisted(tagNewName, in: tagDataSource.updateContext) {
            modalTextFieldDescription = "Tag name '\(tagNewName)' already exists"
            return
        }
        
        // rename if it is not an empty whitespaces
        if !tagNewName.isEmptyOrWhiteSpaces() {
            tag.objectWillChange.send()
            tag.name = tagNewName
            tagDataSource.saveUpdateContext()
            tagDataSource.setUpdateObject(nil)
        }
        
        dismissModalTextField()
    }
    
    func dismissModalTextField() {
        showModalTextField = false
    }
}


struct NoteCardTagView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardTagView(noteCard: .init())
    }
}
