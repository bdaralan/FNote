//
//  NoteCardFormCollectionSelectionView.swift
//  FNote
//
//  Created by Dara Beng on 1/22/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardFormCollectionSelectionView: View {
    
    var viewModel: NoteCardCollectionCollectionViewModel
    
    
    var body: some View {
        CollectionViewWrapper(viewModel: viewModel)
            .navigationBarTitle("Collection")
    }
}


struct NoteCardFormCollectionListView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardFormCollectionSelectionView(viewModel: .init())
    }
}
