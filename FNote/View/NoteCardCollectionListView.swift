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
    @State private var collectionToRename: NoteCardCollection?
    @State private var collectionNewName = ""
    @State private var showSheet = false
    @State private var createRenameSheet = AnyView(EmptyView())
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(noteCardCollectionDataSource.fetchedResult.fetchedObjects ?? [], id: \.uuid) { collection in
                    Button(action: { self.selectCollection(collection: collection) }) {
                        HStack {
                            Text(collection.name)
                            Spacer()
                            Text("34564586790984")
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            Image(systemName: "checkmark")
                                .opacity(collection.uuid == AppCache.currentCollectionUUID ? 1 : 0)
                        }
                    }
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
        .onAppear(perform: fetchAllCollections)
        .sheet(isPresented: $showSheet, content: { self.createRenameSheet })
    }
}

extension NoteCardCollectionListView {
    
    // Nav bar item for adding a new collection
    var createCollectionNavItem: some View {
        Button(action: beginCreateNewCollection) {
            Image(systemName: "plus")
                .imageScale(.large)
        }
    }

    func beginCreateNewCollection() {
        // create a new object
        noteCardCollectionDataSource.prepareNewObject()
        
        // set the object name to empty
        collectionNewName = ""
        
        // show the text field for user to type in. if they remove the entire name, the old name will
        // appear in grey
        createRenameSheet = ModalTextField(isActive: $showSheet, text: $collectionNewName, prompt: "New Collection", placeholder: "Collection Name", onCommit: commitCreateNewCollection).eraseToAnyView()
        showSheet = true
    }
    
    // commit new collection after creating it
    func commitCreateNewCollection() {
        // assign the new object another variable
        let collectionToSave = noteCardCollectionDataSource.newObject!

        // assign the name from the binding to the new name
        collectionToSave.name = collectionNewName
        
        //call save on create context on the data source
        let saveResult = noteCardCollectionDataSource.saveNewObject()
        
        //check result if success, call discard new object on the data source
        switch saveResult {
        case .saved:
            fetchAllCollections()
            showSheet = false
            
            // when user creates a new collection for the first time, that collection will
            // automatically be selected
            if noteCardCollectionDataSource.fetchedResult.fetchedObjects?.count == 1 {
                selectCollection(collection: collectionToSave)
            }
            
        case .failed:
            break
            
        case .unchanged:
            break
        }
        noteCardCollectionDataSource.discardNewObject()
    }
    
    func beginRenameCollection(_ collection: NoteCardCollection) {
        collectionNewName = collection.name
        noteCardCollectionDataSource.setUpdateObject(collection)
        collectionToRename = collection
        createRenameSheet = ModalTextField(isActive: $showSheet, text: $collectionNewName, prompt: "Rename", placeholder: collectionToRename!.name, onCommit: commitRename).eraseToAnyView()
        showSheet = true
    }
    
    func commitRename() {
        // assign the new name to the stored collection
        collectionToRename!.name = collectionNewName
        
        // data source save
        let result = noteCardCollectionDataSource.saveUpdateObject()
        
        switch result {
        case .saved:
            collectionToRename = nil
            noteCardCollectionDataSource.setUpdateObject(nil)
            fetchAllCollections()
            showSheet = false
            
        case .failed:
            break
            
        case .unchanged:
            break
        }
    }
    
    func deleteCollection(_ collection: NoteCardCollection) {
        // check UUID for NoteCard view
        if collection.uuid == AppCache.currentCollectionUUID {
            AppCache.currentCollectionUUID = nil
        }
        // delete
        noteCardCollectionDataSource.delete(collection, saveContext: true)
        
        // update UI
        fetchAllCollections()
        
        // post delete notification
        NotificationCenter.default.post(name: .appCollectionDidDelete, object: collection)
    }
    
    func fetchAllCollections() {
        // create a fetch request
        let request = NoteCardCollection.requestAllCollections()
        noteCardCollectionDataSource.performFetch(request)
        viewReloader.forceReload()
    }
    
    func selectCollection(collection: NoteCardCollection) {
        // post a notification that a collection is selected
        AppCache.currentCollectionUUID = collection.uuid
        viewReloader.forceReload()
        NotificationCenter.default.post(name: .appCurrentCollectionDidChange, object: collection)
    }
}

struct NoteCardCollectionListView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionListView()
    }
}
