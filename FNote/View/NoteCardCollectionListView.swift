//
//  NoteCardCollectionListView.swift
//  FNote
//
//  Created by Brittney Witts on 9/16/19.
//  Copyright © 2019 Brittney Witts. All rights reserved.
//

import SwiftUI

struct NoteCardCollectionListView: View {
    
    @EnvironmentObject var noteCardCollectionDataSource: NoteCardCollectionDataSource
    @State private var collectionToRename: NoteCardCollection?
    @State private var collectionNewName = ""
    @State private var modalTextFieldDescription = ""
    @State private var modalTextFieldPrompt = ""
    @State private var modalTextFieldPlaceholder = ""
    @State private var modalTextFieldState = CreateUpdateSheetState.create
    @State private var showModalTextField = false
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(noteCardCollectionDataSource.fetchedResult.fetchedObjects ?? [], id: \.uuid) { collection in
                    Button(action: { self.selectCollection(collection: collection) }) {
                        
                        // call the collection view
                        NoteCardCollectionListRow(collection: collection)
                            
                            // context menu
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
            }
            .navigationBarTitle("Collections")
            .navigationBarItems(trailing: createCollectionNavItem)  /* place nav bar item - trailing */
        }
        .onAppear(perform: fetchAllCollections)
        .sheet(isPresented: $showModalTextField, content: modalTextField) /* place sheet */
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
        // set the object name to empty
        collectionNewName = ""
        
        // modifying modal text field
        modalTextFieldPrompt = "New Collection"
        modalTextFieldPlaceholder = "Collection Name"
        modalTextFieldDescription = ""
        modalTextFieldState = .create
        
        showModalTextField = true
    }
    
    // commit new collection after creating it
    func commitCreateNewCollection() {
        
        // checking for an empty name
        if collectionNewName.trimmed().isEmpty {
            showModalTextField = false
            return
        }
        
        // checking for duplicate collection name
        if NoteCardCollection.isNameExisted(name: collectionNewName, in: noteCardCollectionDataSource.createContext) {
            modalTextFieldDescription = "Collection name already exists."
            return
        }
        
        noteCardCollectionDataSource.prepareNewObject()
        
        // assign the new object another variable
        let collectionToSave = noteCardCollectionDataSource.newObject!
        
        // assign the name from the binding to the new name
        collectionToSave.name = collectionNewName
        
        // call save on create context on the data source
        let saveResult = noteCardCollectionDataSource.saveNewObject()
        
        // check result if success, call discard new object on the data source
        switch saveResult {
        case .saved:
            fetchAllCollections()
            showModalTextField = false
            
            // when user creates a new collection for the first time, that collection will
            // automatically be selected to show in the Note Cards tab
            if noteCardCollectionDataSource.fetchedResult.fetchedObjects?.count == 1 {
                selectCollection(collection: collectionToSave)
            }
            
        case .failed:
            // if something goes, clear the CreateContext
            noteCardCollectionDataSource.discardCreateContext()
            
        case .unchanged:
            break
        }
        noteCardCollectionDataSource.discardNewObject()
    }
    
    func beginRenameCollection(_ collection: NoteCardCollection) {
        collectionNewName = collection.name
        noteCardCollectionDataSource.setUpdateObject(collection)
        collectionToRename = collection
        
        // modifying modal text field
        modalTextFieldPrompt = "Rename Collection"
        modalTextFieldPlaceholder = collection.name
        modalTextFieldDescription = ""
        modalTextFieldState = .update
        
        showModalTextField = true
    }
    
    func commitRename() {
        // cannot rename the collection the original name
        if collectionNewName == collectionToRename?.name || collectionNewName.trimmed().isEmpty {
            showModalTextField = false
            return
        }
        
        // checking for a duplicate name
        if NoteCardCollection.isNameExisted(name: collectionNewName, in: noteCardCollectionDataSource.createContext) {
            modalTextFieldDescription = "Collection name already exists."
            return
        }
        
        // assign the new name to the stored collection
        collectionToRename!.name = collectionNewName
        
        // data source save
        let result = noteCardCollectionDataSource.saveUpdateObject()
        
        switch result {
        case .saved:
            collectionToRename = nil
            noteCardCollectionDataSource.setUpdateObject(nil)
            fetchAllCollections()
            showModalTextField = false
            
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
    
    func modalTextField() -> some View {
        let commit: () -> Void
        
        switch modalTextFieldState {
        case .create: commit = commitCreateNewCollection
        case .update: commit = commitRename
        }
        
        return ModalTextField(
            isActive: $showModalTextField,
            text: $collectionNewName,
            prompt: modalTextFieldPrompt,
            placeholder: modalTextFieldPlaceholder,
            description: modalTextFieldDescription,
            descriptionColor: .red,
            onCommit: commit
        )
    }
    
    
}

struct NoteCardCollectionListView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionListView()
    }
}
