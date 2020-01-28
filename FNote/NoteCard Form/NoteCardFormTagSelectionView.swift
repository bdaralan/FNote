//
//  NoteCardFormTagSelectionView.swift
//  FNote
//
//  Created by Dara Beng on 1/22/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardFormTagSelectionView: View {
    
    var viewModel: TagCollectionViewModel
    
    
    var body: some View {
        CollectionViewWrapper(viewModel: viewModel)
            .navigationBarTitle("Tags")
    }
}


struct NoteCardFormTagSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardFormTagSelectionView(viewModel: .init())
    }
}
