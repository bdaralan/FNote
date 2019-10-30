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
