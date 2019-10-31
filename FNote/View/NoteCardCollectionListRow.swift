//
//  NoteCardCollectionListRow.swift
//  FNote
//
//  Created by Brittney Witts on 10/30/19.
//  Copyright © 2019 Brittney Witts. All rights reserved.
//

import SwiftUI

struct NoteCardCollectionListRow: View {
    
    @ObservedObject var collection: NoteCardCollection
    
    var showCheckmark: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(collection.name)
                    .font(.headline)
                Spacer()
                Text(self.showCollectionCount(count: collection.noteCards.count))
                    .foregroundColor(.secondary)
                    .font(.subheadline )
                
            }
            
            if showCheckmark {
                Spacer()
                Image(systemName: "checkmark")
                    .transition(.scale)
                    .animation(.easeInOut(duration: 0.3))
            }
        }
    }
}

extension NoteCardCollectionListRow {
    
    func showCollectionCount(count: Int) -> String {
        if count == 1 {
            return "\(count) CARD"
        } else {
            return "\(count) CARDS"
        }
    }
}

struct NoteCardCollectionListRow_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionListRow(collection: .init(), showCheckmark: true)
    }
}
