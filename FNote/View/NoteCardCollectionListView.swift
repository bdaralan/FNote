//
//  NoteCardCollectionListView.swift
//  FNote
//
//  Created by Brittney Witts on 9/16/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardCollectionListView: View {
    
    @EnvironmentObject var noteCardCollectionDataSource: NoteCardCollectionDataSource
    @State var collectionToRename: NoteCardCollection?
    @State var collectionNewName = ""
    @State var showSheet = false
    @State var createRenameSheet = AnyView(EmptyView())
    
    var body: some View {
        NavigationView {
            List {
                ForEach(noteCardCollectionDataSource.fetchedResult.fetchedObjects ?? [], id: \.self) { collection in
                    Text(collection.name)
                    
                        .contextMenu {
                            Button(action: { self.beginRenameCollection(collection) }) {
                                Text("Rename")
                                Image(systemName: "square.and.pencil")
                            }
                            Button(action: { self.deleteCollection(collection) }) {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            .navigationBarTitle("Collections")
            // place nav bar item - trailing
            .navigationBarItems(trailing: createCollectionNavItem)
        }
        // place sheet
        .sheet(isPresented: $showSheet, content: { self.createRenameSheet })
    }
}

extension NoteCardCollectionListView {
    
    // Nav bar item for adding a new collection
    var createCollectionNavItem: some View {
        Button(action: beginCreateNewCollection) {
            Image(systemName: "plus")
        }
    }

    func beginRenameCollection(_ collection: NoteCardCollection) {
        collectionNewName = collection.name
        noteCardCollectionDataSource.setUpdateObject(collection)
        collectionToRename = collection
        showSheet = true
    }
    
    func deleteCollection(_ collection: NoteCardCollection) {
        noteCardCollectionDataSource.delete(collection, saveContext: true)
    }
    
    func renamev() -> some View {
        ModalTextField(isActive: $showSheet, text: $collectionNewName, prompt: "Rename", placeholder: collectionToRename!.name, onCommit: commitRename)
    }
    
    func commitRename() {
        // get the collection
        // assign the new name to the stored collection
        // data source save
    }
    
    func commitCreateNewCollection() {
        // commit new collection
        // when we commit, create a new collection object
        // context is createContext
        // assign the name from the binding to the new name
        showSheet = false
    }
    
    func beginCreateNewCollection() {
        collectionNewName = ""
        createRenameSheet = ModalTextField(isActive: $showSheet, text: $collectionNewName, prompt: "New Collection", placeholder: "Collection Name", onCommit: commitCreateNewCollection).eraseToAnyView()
        showSheet = true
        
    }
}

struct NoteCardCollectionListView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionListView()
    }
}
