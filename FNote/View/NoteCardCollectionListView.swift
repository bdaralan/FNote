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
    @Binding var hasCreateCollectionRequest: Bool
    @State private var collectionToRename: NoteCardCollection?
    @State private var collectionNewName = ""
    @State private var modalTextFieldDescription = ""
    @State private var modalTextFieldPrompt = ""
    @State private var modalTextFieldPlaceholder = ""
    @State private var modalTextFieldState = CreateUpdateSheetState.create
    @State private var showModalTextField = false
    @State private var isModalTextFieldActive = false
    @State private var collectionToDelete: NoteCardCollection?
    @State private var showDeleteCollectionAlert = false
    @ObservedObject private var viewReloader = ViewForceReloader()
        
    var currentCollectionUUID: String? {
        AppCache.currentCollectionUUID
    }
    
    
    // MARK: Body
    
    var body: some View {
        NavigationView {
            List {
                ForEach(noteCardCollectionDataSource.fetchedObjects, id: \.uuid) { collection in
                    Button(action: { self.setCurrentCollection(collection) }) {
                        // call the collection view
                        NoteCardCollectionListRow(
                            collection: collection,
                            showCheckmark: collection.uuid == self.currentCollectionUUID
                        )
                            .contextMenu(menuItems: { self.contextMenuItems(for: collection) })
                    }
                }
            }
            .navigationBarTitle("Collections")
            .navigationBarItems(trailing: createCollectionNavItem)  /* place nav bar item - trailing */
        }
        .onAppear(perform: setupView)
        .sheet(isPresented: $showModalTextField, content: modalTextField) /* place sheet */
        .alert(isPresented: $showDeleteCollectionAlert, content: { self.deleteCollectionAlert })
    }
}


// MARK: Context Menu Item

extension NoteCardCollectionListView {
    
    func contextMenuItems(for collection: NoteCardCollection) -> some View {
        let rename = { self.beginRenameCollection(collection) }
        let delete = { self.beginDeleteCollection(collection) }
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
    
    func setCurrentCollection(_ collection: NoteCardCollection) {
        AppCache.currentCollectionUUID = collection.uuid
        viewReloader.forceReload()
        NotificationCenter.default.post(name: .appCurrentCollectionDidChange, object: collection)
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
        
        isModalTextFieldActive = true
        showModalTextField = true
    }
    
    func cancelCreateCollection() {
        isModalTextFieldActive = false
        showModalTextField = false
    }
    
    // commit new collection after creating it
    func commitCreateNewCollection() {
        // checking for an empty name
        if collectionNewName.trimmed().isEmpty {
            isModalTextFieldActive = false
            showModalTextField = false
            return
        }
        
        // checking for duplicate collection name
        let context = noteCardCollectionDataSource.createContext
        if NoteCardCollection.isNameExisted(name: collectionNewName, in: context) {
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
            
            // when user creates a new collection for the first time, that collection will
            // automatically be selected to show in the Note Cards tab
            let isOnlyCollection = noteCardCollectionDataSource.fetchedObjects.count == 1
            let isNoCollectionSelected = AppCache.currentCollectionUUID == nil
            if isOnlyCollection || isNoCollectionSelected {
                setCurrentCollection(collectionToSave)
            }
            
        case .failed:
            // if something goes wrong, clear the CreateContext
            noteCardCollectionDataSource.discardCreateContext()
            
        case .unchanged:
            break
        }
        
        noteCardCollectionDataSource.discardNewObject()
        isModalTextFieldActive = false
        showModalTextField = false
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
        
        isModalTextFieldActive = true
        showModalTextField = true
    }
    
    func cancelRenameCollection() {
        noteCardCollectionDataSource.setUpdateObject(nil)
        collectionToRename = nil
        isModalTextFieldActive = false
        showModalTextField = false
    }
    
    func commitRenameCollection() {
        // cannot rename the collection the original name
        if collectionNewName == collectionToRename?.name || collectionNewName.trimmed().isEmpty {
            isModalTextFieldActive = false
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
            
        case .failed:
            break
            
        case .unchanged:
            break
        }
        
        isModalTextFieldActive = false
        showModalTextField = false
    }
    
    func modalTextField() -> some View {
        let commit: () -> Void
        let cancel: () -> Void
        
        switch modalTextFieldState {
        case .create:
            commit = commitCreateNewCollection
            cancel = cancelCreateCollection
        case .update:
            commit = commitRenameCollection
            cancel = cancelRenameCollection
        }
        
        return ModalTextField(
            isActive: $isModalTextFieldActive,
            text: $collectionNewName,
            prompt: modalTextFieldPrompt,
            placeholder: modalTextFieldPlaceholder,
            description: modalTextFieldDescription,
            descriptionColor: .red,
            onCancel: cancel,
            onCommit: commit
        )
    }
}


// MARK: - Delete & Alert

extension NoteCardCollectionListView {
    
    var deleteCollectionAlert: Alert {
        guard let collection = collectionToDelete else {
            fatalError("🧨 attempt to delete collection but does not have a reference to it 💣")
        }
        
        let delete = Alert.Button.destructive(Text("Delete"), action: {
            self.commitDeleteCollection(collection)
        })
        
        return Alert(
            title: Text("Delete '\(collection.name)'"),
            message: Text("Deleting a collection will also delete its note cards."),
            primaryButton: .cancel(),
            secondaryButton: delete
        )
    }
    
    func beginDeleteCollection(_ collection: NoteCardCollection) {
        // keep a reference to the collection so the alert can delete it
        collectionToDelete = collection
        showDeleteCollectionAlert = true
    }
    
    func commitDeleteCollection(_ collection: NoteCardCollection) {
        // check UUID for NoteCard view
        if collection.uuid == currentCollectionUUID {
            AppCache.currentCollectionUUID = nil
        }
        
        // grab the uuid to pass into notification object
        // because after deleting, the context will erase the collection data
        let collectionUUID = collection.uuid
        
        // delete
        noteCardCollectionDataSource.delete(collection, saveContext: true)
        collectionToDelete = nil // don't need to keep the reference any more
        
        // update UI
        fetchAllCollections()
        
        // post delete notification
        NotificationCenter.default.post(name: .appCollectionDidDelete, object: collectionUUID)
    }
}


extension NoteCardCollectionListView {
    
    func setupView() {
        fetchAllCollections()
        if hasCreateCollectionRequest {
            hasCreateCollectionRequest = false
            beginCreateNewCollection()
        }
    }
    
    func fetchAllCollections() {
        // create a fetch request
        let request = NoteCardCollection.requestAllCollections()
        noteCardCollectionDataSource.performFetch(request)
        viewReloader.forceReload()
    }
}


struct NoteCardCollectionListView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionListView(hasCreateCollectionRequest: .constant(false))
    }
}
