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
    
    var showQuickButton: Bool = true
    
    var cardBackground: Color?
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(noteCard.native)
                .font(.title)
                .foregroundColor(.primary)
            
            Divider()
                .background(Color.noteCardDivider)
            
            Text(noteCard.translation)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack (alignment: .center) {
                relationshipButton()
                Spacer()
                tagButton()
                Spacer()
                formalButton()
                Spacer()
                starButton()
            }
            .padding(.top, 4)
            .hidden(!showQuickButton)
        }
        .padding()
        .background(cardBackground ?? .noteCardBackground)
        .cornerRadius(15)
        .shadow(color: Color.primary.opacity(0.1), radius: 1, x: -1, y: 1)
    }
}


extension NoteCardCollectionViewCard {
    
    func relationshipButton() -> some View {
        Button(action: testWord) {
            HStack {
                Image.noteCardRelationship
                Text("\(noteCard.relationships.count)")
                    .font(.body)
            }
            .foregroundColor(.primary)
        }
    }
    
    func tagButton() -> some View {
        HStack {
            Image.noteCardTag
            Text("\(noteCard.tags.count)")
        }
        .font(.body)
        .foregroundColor(.primary)
    }
    
    func formalButton() -> some View {
        HStack {
            Image.noteCardFormality
            Text(noteCard.formality == .notset ? " " : noteCard.formality.abbreviation)
        }
        .font(.body)
        .foregroundColor(noteCard.formality.color)
    }
    
    func starButton() -> some View {
        Button(action: toggleNoteCardFavorite) {
            Image.noteCardFavorite(noteCard.isFavorited)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
    
    func toggleNoteCardFavorite() {
        noteCard.isFavorited.toggle()
        noteCard.managedObjectContext?.quickSave()
        noteCard.managedObjectContext?.parent?.quickSave()
    }
}


struct NoteCardCollectionViewCard_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionViewCard(noteCard: .init())
    }
}
