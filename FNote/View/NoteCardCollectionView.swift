//
//  NoteCardCollectionView.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardCollectionView: View {
    
    @EnvironmentObject var noteCardCollectionDataSource: NoteCardCollectionDataSource
    
    @ObservedObject var collection: NoteCardCollection
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 16) {
                    ForEach(Array(collection.noteCards), id: \.self) { index in
                        NavigationLink(destination: NoteCardView().navigationBarTitle("Note Card", displayMode: .inline)) {
                            NoteCardCollectionViewCard()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.vertical)
            }
            .navigationBarTitle(collection.name)
        }
    }
}


struct NoteCardCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionView(collection: NoteCardCollection.sampleCollections(count: 1, noteCount: 20)[0])
    }
}
