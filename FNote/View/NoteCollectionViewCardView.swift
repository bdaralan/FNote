//
//  NoteCardCollectionViewCard.swift
//  FNote
//
//  Created by Veronica Sumariyanto on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardCollectionViewCard: View {
    
    @ObservedObject var noteCard: NoteCard
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text(noteCard.navtive)
                    .font(.title)
                .padding(.horizontal)
                .padding(.vertical, 5)
                
                Divider()
                    .padding(.horizontal)
                Text(noteCard.translation)
                    .font(.title)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    
                HStack (alignment: .center) {
                    wordButton()
                    Spacer()
                    tagButton()
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
                .font(.body)
        }
    }
    
    func tagButton() -> some View {
        
        var tagNumber: String
        
        tagNumber = String(noteCard.tags.count)
        
        return Button(action: testTag) {
            HStack{
                Image(systemName: "tag.fill")
                Text(tagNumber)
                    .font(.body)
            }
        }
    }
    
    // Function that tests button functionality. Creates a tag, adds it to the notecard, and shows in the view.
    func testTag()
    {
        let exampleTag = Tag(context: noteCard.managedObjectContext!) // the exclamation mark forces the context to exist
        exampleTag.name = "greetings"
        noteCard.objectWillChange.send()
        noteCard.addToTags(exampleTag)
    }
    
    func wordButton() -> some View {
        var wordNumber: String
        
        wordNumber = String(noteCard.relationships.count)
        
        return Button(action: testWord) {
            HStack{
                Image(systemName: "circle.grid.hex")
                Text(wordNumber)
                    .font(.body)
            }
        }
    }
    
    // Function that tests button functionality. Creates a notecard, adds it to the notecard, and shows in the view.
    func testWord()
    {
        let exampleNoteCard = NoteCard(context: noteCard.managedObjectContext!)
        exampleNoteCard.navtive = "Bonjour"
        exampleNoteCard.translation = "Hello"
        noteCard.objectWillChange.send()
        noteCard.addToRelationships(exampleNoteCard)
    }
}


struct NoteCardCollectionViewCard_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionViewCard(noteCard: .init())
    }
}
