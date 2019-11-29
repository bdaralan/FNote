//
//  TagListView.swift
//  FNote
//
//  Created by Brittney Witts on 9/25/19.
//  Copyright © 2019 Brittney Witts. All rights reserved.
//

import SwiftUI

struct TagListView: View {
    
    @EnvironmentObject var tagDataSource: TagDataSource
    @State private var tagToRename: Tag?
    @State private var tagNewName = ""
    @State private var modalTextFieldDescription = ""
    @State private var modalTextFieldPrompt = ""
    @State private var modalTextFieldPlaceholder = ""
    @State private var isModalTextFieldActive = false
    @State private var sheet: Sheet?
    @State private var tagToDelete: Tag?
    @State private var showDeleteTagAlert = false
    @State private var previewNoteCards = [NoteCard]()
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    
    // MARK: Body
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tagDataSource.fetchedObjects, id: \.self) { tag in
                    Button(action: { self.showNoteCardPreviewSheet(for: tag) }) {
                        TagListRow(tag: tag)
                            .contextMenu(menuItems: { self.contextMenuItems(for: tag) })
                    }
                }
            }
            .navigationBarTitle("Tags") /* nav bar title goes here */
            .navigationBarItems(trailing: createTagNavItem) /* nav bar button goes here */
        }
        .onAppear(perform: fetchAllTags)
        .sheet(item: $sheet, onDismiss: dismissSheet, content: presentationSheet)
        .alert(isPresented: $showDeleteTagAlert, content: { self.deleteTagAlert })
    }
}


extension TagListView {
    
    func contextMenuItems(for tag: Tag) -> some View {
        let rename = { self.beginRenameTag(tag) }
        let delete = { self.beginDeleteTag(tag) }
        return Group {
            Button(action: rename) {
                Text("Rename")
                Image(systemName: "square.and.pencil")
            }
            Button(action: delete) {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
}


// MARK: - Create Tag

extension TagListView {
    
    //Nav bar item for adding a new tag
    var createTagNavItem: some View {
        Button(action: beginCreateNewTag) {
            Image(systemName: "plus")
                .imageScale(.large)
        }
        .buttonStyle(NavigationItemIconStyle())
    }
    
    var createTagSheet: some View {
        ModalTextField(
            text: $tagNewName,
            isFirstResponder: $isModalTextFieldActive,
            prompt: modalTextFieldPrompt,
            placeholder: modalTextFieldPlaceholder,
            description: modalTextFieldDescription,
            descriptionColor: .red,
            onCancel: cancelCreateNewTag,
            onCommit: commitCreateNewTag
        )
    }
    
    func beginCreateNewTag() {
        // set the object name to empty
        tagNewName = ""
        
        // modifying modal text field
        modalTextFieldPrompt = "New Tag"
        modalTextFieldPlaceholder = "Tag Name"
        modalTextFieldDescription = ""
        
        isModalTextFieldActive = true
        sheet = .createTag
    }
    
    func cancelCreateNewTag() {
        isModalTextFieldActive = false
        sheet = nil
    }
    
    // commit new tag after creating it
    func commitCreateNewTag() {
        
        // checking for an empty name
        if tagNewName.trimmed().isEmpty {
            isModalTextFieldActive = false
            sheet = nil
            return
        }
        
        // checking for a duplicate name
        if Tag.isNameExisted(name: tagNewName, in: tagDataSource.createContext) {
            modalTextFieldDescription = "Tag name already exists."
            return
        }
        
        tagDataSource.prepareNewObject()
        
        // assign the new object another variable
        let tagToSave = tagDataSource.newObject!
        
        // assign the name from the binding to the new name
        tagToSave.name = tagNewName
        
        // call save on create context on the data source
        let saveResult = tagDataSource.saveNewObject()
        
        // check result, if success, call discard new object on the data source
        switch saveResult {
        case .saved:
            fetchAllTags()
            dismissSheet()
            
        case .failed:
            // if something goes wrong, clear the CreateContext
            tagDataSource.discardCreateContext()
            
        case .unchanged:
            break
        }
        tagDataSource.discardNewObject()
    }
}


// MARK: - Rename Tag

extension TagListView {
    
    var renameTagSheet: some View {
        ModalTextField(
            text: $tagNewName,
            isFirstResponder: $isModalTextFieldActive,
            prompt: modalTextFieldPrompt,
            placeholder: modalTextFieldPlaceholder,
            description: modalTextFieldDescription,
            descriptionColor: .red,
            onCancel: cancelRenameTag,
            onCommit: commitRename
        )
    }
    
    func beginRenameTag(_ tag: Tag) {
        tagNewName = tag.name
        tagDataSource.setUpdateObject(tag)
        tagToRename = tag
        
        // modifying modal text field
        modalTextFieldPrompt = "Rename Tag"
        modalTextFieldPlaceholder = tag.name
        modalTextFieldDescription = ""
        
        isModalTextFieldActive = true
        sheet = .renameTag
    }
    
    func cancelRenameTag() {
        isModalTextFieldActive = false
        sheet = nil
    }
    
    func commitRename() {
        // cannot rename the tag to the original name
        if tagNewName == tagToRename?.name || tagNewName.trimmed().isEmpty {
            dismissSheet()
            return
        }
        
        // checking for a duplicate name
        if Tag.isNameExisted(name: tagNewName, in: tagDataSource.createContext) {
            modalTextFieldDescription = "Tag name already exists."
            return
        }
        
        // assign the new name to the stored tag
        tagToRename!.name = tagNewName
        
        // data source save
        let result = tagDataSource.saveUpdateObject()
        
        switch result {
        case .saved:
            tagToRename = nil
            tagDataSource.setUpdateObject(nil)
            fetchAllTags()
            dismissSheet()
            
        case .failed:
            break
            
        case .unchanged:
            break
        }
    }
}


// MARK: - Delete Tag

extension TagListView {
    
    var deleteTagAlert: Alert {
        guard let tag = tagToDelete else {
            fatalError("🧨 attempt to delete tag but does not have a reference to it 💣")
        }
        
        let delete = Alert.Button.destructive(Text("Delete")) {
            self.commitDeleteTag(tag)
        }
        
        return Alert(
            title: Text("Delete '\(tag.name)'"),
            message: Text("Delete a tag will also remove it from the note cards"),
            primaryButton: .cancel(),
            secondaryButton: delete
        )
    }
    
    func beginDeleteTag(_ tag: Tag) {
        tagToDelete = tag
        showDeleteTagAlert = true
    }
    
    func commitDeleteTag(_ tag: Tag) {
        // delete
        tagDataSource.delete(tag, saveContext: true)
        tagToDelete = nil
        
        // update UI
        fetchAllTags()
        
        // post delete notification
        NotificationCenter.default.post(name: .appCurrentTagDidDelete, object: tag)
    }
}


// MARK: - Note Card Preview

extension TagListView {
    
    var noteCardPreviewSheet: some View {
        let doneNavItem = Button("Done", action: dismissNoteCardPreviewSheet)
        return NavigationView {
            NoteCardScrollView(
                noteCards: previewNoteCards,
                selectedCards: [],
                showQuickButtons: false,
                searchContext: tagDataSource.fetchedResult.managedObjectContext,
                onTap: handlePreviewNoteCardTapped
            )
                .navigationBarTitle("Note Cards", displayMode: .inline)
                .navigationBarItems(leading: doneNavItem)
        }
    }
    
    func showNoteCardPreviewSheet(for tag: Tag) {
        previewNoteCards = tag.noteCards.sorted(by: { $0.translation < $1.translation })
        sheet = .noteCardPreview
    }
    
    func dismissNoteCardPreviewSheet() {
        previewNoteCards = []
        sheet = nil
    }
    
    func handlePreviewNoteCardTapped(_ noteCard: NoteCard) {
        dismissNoteCardPreviewSheet()
        NotificationCenter.default.post(name: .requestDisplayingNoteCard, object: noteCard)
    }
}


// MARK: - Sheet

extension TagListView {
    
    enum Sheet: Identifiable {
        case noteCardPreview
        case renameTag
        case createTag
        
        var id: Sheet { self }
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .noteCardPreview:
            return noteCardPreviewSheet.eraseToAnyView()
        case .renameTag:
            return renameTagSheet.eraseToAnyView()
        case .createTag:
            return createTagSheet.eraseToAnyView()
        }
    }
    
    func dismissSheet() {
        dismissNoteCardPreviewSheet()
        isModalTextFieldActive = false
        sheet = nil
    }
}


// MARK: - Fetch Tag

extension TagListView {
    
    func fetchAllTags() {
        // create a fetch request
        let request = Tag.requestAllTags()
        
        tagDataSource.performFetch(request)
        viewReloader.forceReload()
    }
}


struct TagListView_Previews: PreviewProvider {
    static var previews: some View {
        TagListView()
    }
}
