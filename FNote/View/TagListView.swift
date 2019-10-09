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
    @State private var showSheet = false
    @State private var createRenameSheet = AnyView(EmptyView())
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tagDataSource.fetchedResult.fetchedObjects ?? [], id: \.self) { tag in
                    Text(tag.name)
                        
                        .contextMenu {
                            Button(action: { self.beginRenameTag(tag) }) {
                                Text("Rename")
                                Image(systemName: "square.and.pencil")
                            }
                            Button(action: { self.deleteTag(tag) }) {
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
            .sheet(isPresented: $showSheet, content: { self.createRenameSheet})
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
        // create new object
        tagDataSource.prepareNewObject()
        
        // set the object name to empty
        tagNewName = ""
        
        // show the text field for user to type in. if they remove the entire name, the old name will
        // appear in grey
        createRenameSheet = ModalTextField(isActive: $showSheet, text: $tagNewName, prompt: "New Tag", placeholder: "Tag Name", onCommit: commitCreateNewTag).eraseToAnyView()
        
        showSheet = true
    }
    
    func commitCreateNewTag() {
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
            showSheet = false
            
        case .failed:
            break
            
        case .unchanged:
            break
        }
        tagDataSource.discardNewObject()
        
    }
    
    func beginRenameTag(_ tag: Tag) {
        tagNewName = tag.name
        tagDataSource.setUpdateObject(tag)
        tagToRename = tag
        createRenameSheet = ModalTextField(isActive: $showSheet, text: $tagNewName, prompt: "Rename", placeholder: tagToRename!.name, onCommit: commitRename).eraseToAnyView()
        showSheet = true
    }
    
    func commitRename() {
        // assign the new name to the stored tag
        tagToRename!.name = tagNewName
        
        // data source save
        let result = tagDataSource.saveUpdateObject()
        
        switch result {
        case .saved:
            tagToRename = nil
            tagDataSource.setUpdateObject(nil)
            fetchAllTags()
            showSheet = false
            
        case .failed:
            break
            
        case .unchanged:
            break
        }
    }
    
    func deleteTag(_ tag: Tag) {
        // delete
        tagDataSource.delete(tag, saveContext: true)
        
        // update UI
        fetchAllTags()
        
        // post delete notification
        NotificationCenter.default.post(name: .appCurrentTagDidDelete, object: tag)
    }
    
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

