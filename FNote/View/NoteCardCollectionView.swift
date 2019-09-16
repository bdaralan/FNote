//
//  NoteCardCollectionView.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardCollectionView: View {
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                ForEach(1...10, id: \.self) { index in
                    NoteCardCollectionViewCard()
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
