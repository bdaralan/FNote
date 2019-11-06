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
    @State private var modalTextFieldState = CreateUpdateSheetState.create
    @State private var showModalTextField = false
    @State private var tagToDelete: Tag?
    @State private var showDeleteTagAlert = false
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tagDataSource.fetchedResult.fetchedObjects ?? [], id: \.self) { tag in
                    
                    // call the tag view
                    TagListRow(tag: tag)
                        
                        //context menu
                    .contextMenu {
                        Button(action: { self.beginRenameTag(tag) }) {
                            Text("Rename")
                            Image(systemName: "square.and.pencil")
                        }
                        Button(action: { self.beginDeleteTag(tag) }) {
                            Text("Delete")
                            Image(systemName: "trash")
                        }
                    }
                }
            }
                // nav bar title goes here
                // nav bar button goes here
                .navigationBarTitle("Tags")
                .navigationBarItems(trailing: createTagNavItem)
            
        }
            // place sheet
            .onAppear(perform: fetchAllTags)
            .sheet(isPresented: $showModalTextField, content: modalTextField) /* place sheet */
            .alert(isPresented: $showDeleteTagAlert, content: { self.deleteTagAlert })
    }
}


extension TagListView {
    
    //Nav bar item for adding a new tag
    var createTagNavItem: some View {
        Button(action: beginCreateNewTag) {
            Image(systemName: "plus")
                .imageScale(.large)
        }
    }
    
    func beginCreateNewTag() {
        // set the object name to empty
        tagNewName = ""
        
        // modifying modal text field
        modalTextFieldPrompt = "New Tag"
        modalTextFieldPlaceholder = "Tag Name"
        modalTextFieldDescription = ""
        modalTextFieldState = .create
        
        showModalTextField = true
    }
    
    // commit new tag after creating it
    func commitCreateNewTag() {
        
        // checking for an empty name
        if tagNewName.trimmed().isEmpty {
            showModalTextField = false
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
            showModalTextField = false
            
        case .failed:
            // if something goes wrong, clear the CreateContext
            tagDataSource.discardCreateContext()
            
        case .unchanged:
            break
        }
        tagDataSource.discardNewObject()
    }
    
    func beginRenameTag(_ tag: Tag) {
        tagNewName = tag.name
        tagDataSource.setUpdateObject(tag)
        tagToRename = tag
        
        // modifying modal text field
        modalTextFieldPrompt = "Rename Tag"
        modalTextFieldPlaceholder = tag.name
        modalTextFieldDescription = ""
        modalTextFieldState = .update
        
        showModalTextField = true
    }
    
    func commitRename() {
        // cannot rename the tag to the original name
        if tagNewName == tagToRename?.name {
            showModalTextField = false
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
            showModalTextField = false
            
        case .failed:
            break
            
        case .unchanged:
            break
        }
    }
    
    func fetchAllTags() {
        // create a fetch request
        let request = Tag.requestAllTags()
        
        tagDataSource.performFetch(request)
        viewReloader.forceReload()
    }
    
    func modalTextField() -> some View {
        let commit: () -> Void
        
        switch modalTextFieldState {
        case .create: commit = commitCreateNewTag
        case .update: commit = commitRename
        }
        
        return ModalTextField(
            isActive: $showModalTextField,
            text: $tagNewName,
            prompt: modalTextFieldPrompt,
            placeholder: modalTextFieldPlaceholder,
            description: modalTextFieldDescription,
            descriptionColor: .red,
            onCommit: commit
        )
    }
}


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


struct TagListView_Previews: PreviewProvider {
    static var previews: some View {
        TagListView()
    }
}
