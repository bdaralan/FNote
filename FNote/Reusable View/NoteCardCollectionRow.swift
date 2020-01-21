//
//  NoteCardCollectionRow.swift
//  FNote
//
//  Created by Brittney Witts on 10/30/19.
//  Copyright © 2019 Brittney Witts. All rights reserved.
//

import SwiftUI

struct NoteCardCollectionRow: View {
    
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
            
            Spacer()
            
            if showCheckmark {
                Image(systemName: "checkmark")
                    .transition(AnyTransition.scale.animation(Animation.easeInOut(duration: 0.15)))
            }
        }
        .padding()
        .background(Color.noteCardBackground)
        .cornerRadius(10)
        .shadow(color: Color.primary.opacity(0.1), radius: 1, x: -1, y: 1)
    }
}

extension NoteCardCollectionRow {
    
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
        NoteCardCollectionRow(collection: .init(), showCheckmark: true)
    }
}
