//
//  NoteCardCollectionViewCard.swift
//  FNote
//
//  Created by Veronica Sumariyanto on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardCollectionViewCard: View {
    
    @ObservedObject var noteCard = NoteCard.sampleNoteCards(count: 1)[0]
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(noteCard.navtive)
                        .font(.title)
                    Spacer()
                    Image(systemName: "ellipsis")
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                
                Divider()
                    .padding(.horizontal)
                Text(noteCard.translation)
                    .font(.title)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    
                HStack (alignment: .center) {
                    quickButton(imageName: "tag.fill", label: "0")
                    Spacer()
                    quickButton(imageName: "circle.grid.hex.fill", label: "0")
                    Spacer()
                    quickButton(imageName: "hand.raised.fill", label: "U")
                    Spacer()
                    quickButton(imageName: "star", label: "0")
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .background(Color.white)
        }
        .cornerRadius(20)
        .padding()
        .background(Color.init(red: 225/255, green: 225/255, blue: 225/255))
    }
}


extension NoteCardCollectionViewCard {
    
    func quickButton(imageName: String, label: String) -> some View {
        Group {
            Image(systemName: imageName)
            Text(label)
                .font(.caption)
        }
    }
}


struct NoteCardCollectionViewCard_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionViewCard()
    }
}
