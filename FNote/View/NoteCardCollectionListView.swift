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
    @State var sampleCollection = NoteCardCollection.sampleCollections(count: 10, noteCount: 1)
    @State var collectionToRename: NoteCardCollection?
    @State var collectionNewName = ""
    @State var showRenameSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sampleCollection, id: \.self) { collection in
                    Text(collection.name)
                    
                        .contextMenu {
                            Button(action: { self.renameCollection(collection) }) {
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
        }
    .sheet(isPresented: $showRenameSheet, content: renamev)
    }
}

extension NoteCardCollectionListView {

    func renameCollection(_ collection: NoteCardCollection) {
        // rename the collection to what the user wants
        collectionNewName = collection.name
//        noteCardCollectionDataSource.setUpdateObject(collection)
        collectionToRename = collection
        showRenameSheet = true
    }
    
    func deleteCollection(_ collection: NoteCardCollection) {
        // delete the collection
        let index = sampleCollection.firstIndex(of: collection)!
        sampleCollection.remove(at: index)
    }
    
    func renamev() -> some View {
        ModalTextField(isActive: $showRenameSheet, text: $collectionNewName, prompt: "Rename", placeholder: collectionToRename!.name, onCommit: commitRename)
    }
    
    func commitRename() {
        // validate before we save
        // save
    }
}

struct NoteCardCollectionListView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionListView()
    }
}
