//
//  NoteCardCollectionView.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardCollectionView: View {
    
    var collection: NoteCardCollection = NoteCardCollection.sampleCollections(count: 1, cardCount: -1)[0]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                ForEach(Array(collection.noteCards), id: \.self) { index in
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 100, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

struct NoteCardCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionView()
    }
}
