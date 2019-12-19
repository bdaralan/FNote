//
//  TagListRow.swift
//  FNote
//
//  Created by Andrew Flores on 10/30/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct TagListRow: View {
    
    @ObservedObject var tag: Tag
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(tag.name)
                .font(.headline)
            Spacer()
            Text(self.showTagCount(count: tag.noteCards.count))
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(Color.noteCardBackground)
        .cornerRadius(10)
        .shadow(color: Color.primary.opacity(0.1), radius: 1, x: -1, y: 1)
    }
}

extension TagListRow {
    
    func showTagCount(count: Int) -> String {
        if count == 1 {
            return "\(count) CARD"
        } else {
            return "\(count) CARDS"
        }
    }
}

struct TagListRow_Previews: PreviewProvider {
    static var previews: some View {
        TagListRow(tag: .init())
    }
}
