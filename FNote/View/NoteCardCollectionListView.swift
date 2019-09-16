//
//  NoteCardCollectionListView.swift
//  FNote
//
//  Created by Brittney Witts on 9/16/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardCollectionListView: View {
    
    @State var sampleCollection = NoteCardCollection.sampleCollections(count: 10, noteCount: 1)
    
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
    }
}

extension NoteCardCollectionListView {

    func renameCollection(_ collection: NoteCardCollection) {
        // rename the collection to what the user wants
    }
    
    func deleteCollection(_ collection: NoteCardCollection) {
        // delete the collection
        let index = sampleCollection.firstIndex(of: collection)!
        sampleCollection.remove(at: index)
    }
    
}

struct NoteCardCollectionListView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionListView()
    }
}
