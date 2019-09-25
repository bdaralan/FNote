//
//  TagListView.swift
//  FNote
//
//  Created by Brittney Witts on 9/25/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
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
        
    }
    
    func beginRenameTag(_ tag: Tag) {
        
    }
    
    func deleteTag(_ tag: Tag) {
        
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

