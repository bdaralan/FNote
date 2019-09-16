//
//  NoteCardCollectionListView.swift
//  FNote
//
//  Created by Brittney Witts on 9/11/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardCollectionListView: View {
    
    var sampleCollection = NoteCardCollection.sampleCollections(count: 10, noteCount: 1)
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sampleCollection, id: \.self) { collection in
                    Button(action: { self.collectionTapped(collection) }) { //
                        Text(collection.name) // button label
                    }
                }
            }
            .navigationBarTitle("Collections")
        }
    }
}

// button action
// needs to be selected and have a check mark on the right side
extension NoteCardCollectionListView {
    
    func collectionTapped(_ collection: NoteCardCollection) {
        
    }
}

struct NoteCardCollectionListView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionListView()
    }
}
