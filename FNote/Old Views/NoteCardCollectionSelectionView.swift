//
//  NoteCardCollectionSelectionView.swift
//  FNote
//
//  Created by Dara Beng on 12/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardCollectionSelectionView: View {
    
    var title: String
    
    var collections: [NoteCardCollection]
    
    var disableCollections: [NoteCardCollection]
    
    var onSelected: ((NoteCardCollection) -> Void)
    
    var onDone: (() -> Void)
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(collections) { collection in
                        NoteCardCollectionRow(collection: collection)
                            .onTapGesture(perform: { self.onSelected(collection) })
                            .disabled(self.disableCollections.contains(collection))
                            .opacity(self.disableCollections.contains(collection) ? 0.4 : 1)
                    }
                }
                .padding()
            }
            .navigationBarTitle(Text(title), displayMode: .inline)
            .navigationBarItems(leading: doneNavItem)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


extension NoteCardCollectionSelectionView {
    
    var doneNavItem: some View {
        Button("Done", action: onDone)
    }
}


struct NoteCardCollectionSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionSelectionView(title: "Title", collections: [], disableCollections: [], onSelected: { _ in }, onDone: {})
    }
}
