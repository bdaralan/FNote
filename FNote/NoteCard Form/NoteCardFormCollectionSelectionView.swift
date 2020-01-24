//
//  NoteCardFormCollectionSelectionView.swift
//  FNote
//
//  Created by Dara Beng on 1/22/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardFormCollectionSelectionView: View {
    
    @ObservedObject var formModel: NoteCardFormModel
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 16) {
                ForEach(formModel.selectableCollections) { collection in
                    NoteCardCollectionRow(collection: collection)
                        .onTapGesture(perform: { self.formModel.onCollectionSelected?(collection) })
                        .disabled(collection === self.formModel.selectedCollection)
                        .opacity(collection === self.formModel.selectedCollection ? 0.5 : 1)
                }
            }
            .padding()
        }
        .navigationBarTitle("Collection")
    }
}


struct NoteCardFormCollectionListView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardFormCollectionSelectionView(formModel: .init(collection: .sample))
    }
}
