//
//  NoteCardCollectionView.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardCollectionView: View {
    
    @ObservedObject var collection: NoteCardCollection
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 16) {
                    ForEach(Array(collection.noteCards), id: \.self) { index in
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: 120, alignment: .center)
                            .foregroundColor(.red)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 1, y: 1)
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
