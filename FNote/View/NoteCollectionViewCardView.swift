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
        ZStack {
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
                    formalButton()
                    Spacer()
                    starButton()
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .background(Color.white)
            .cornerRadius(20)
       //     .shadow(color: Color.black.opacity(1), radius: 3 , x: 4, y: 1)
        }
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
    
    func starButton() -> some View {
        var starImage: String
          
        if noteCard.isFavorited {
            starImage = "star.fill"
        }
        else {
            starImage = "star"
        }
        
        return Image(systemName: starImage)
    }
    
    func formalButton() -> some View {
        let formal: String
        
        switch noteCard.formality {
        case .unknown:
            formal = "?"
        case .informal:
            formal = "I"
        case .neutral:
            formal = "N"
        case .formal:
            formal = "F"
        }
        
        return Group {
            Image(systemName: "hand.raised.fill")
            Text(formal)
                .font(.caption)
        }
    }
}


struct NoteCardCollectionViewCard_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionViewCard()
    }
}
