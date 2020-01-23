//
//  NoteCardFormRelationshipSelectionView.swift
//  FNote
//
//  Created by Dara Beng on 1/22/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardFormRelationshipSelectionView: View {
        
    var viewModel: NoteCardCollectionViewModel
    
    var body: some View {
        NoteCardCollectionViewWrapper(viewModel: viewModel)
            .navigationBarTitle("Relationships")
    }
}


struct NoteCardFormRelationshipSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardFormRelationshipSelectionView(viewModel: .init())
    }
}
