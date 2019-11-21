//
//  NoteCardCollectionViewCard.swift
//  FNote
//
//  Created by Veronica Sumariyanto on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardCollectionViewCard: View {
    
    @EnvironmentObject var noteCardDataSource: NoteCardDataSource
    
    @ObservedObject var noteCard: NoteCard
    
    var showQuickButtons: Bool = true
    
    var cardBackground: Color?
    
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    @State private var sheet: Sheet?
    
    @State private var relationshipNoteCards = [NoteCard]()
    
    /// A view model used to handle search.
    let noteCardSearchModel = NoteCardSearchModel()
    
    
    // MARK: Body
    
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
            .hidden(!showQuickButtons)
        }
        .padding()
        .background(cardBackground ?? .noteCardBackground)
        .cornerRadius(15)
        .shadow(color: Color.primary.opacity(0.1), radius: 1, x: -1, y: 1)
        .sheet(item: $sheet, onDismiss: dismissSheet, content: previewSheet)
    }
}


extension NoteCardCollectionViewCard {
    
    func relationshipButton() -> some View {
        Button(action: beginPreviewRelationships) {
            HStack {
                Image.noteCardRelationship
                Text("\(noteCard.relationships.count)")
                    .font(.body)
            }
            .foregroundColor(.primary)
        }
    }
    
    func tagButton() -> some View {
        Button(action: {}) {
            HStack {
                Image.noteCardTag
                Text("\(noteCard.tags.count)")
            }
            .font(.body)
            .foregroundColor(.primary)
        }
    }
    
    func formalButton() -> some View {
        Button(action: {}) {
            HStack {
                Image.noteCardFormality
                Text(noteCard.formality.abbreviation)
            }
            .font(.body)
            .foregroundColor(noteCard.formality.color)
        }
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
        viewReloader.forceReload()
    }
}


// MARK: - Relationships Preview Sheet

extension NoteCardCollectionViewCard {
    
    /// A sheet that previews the related cards of the selected card.
    var relationshipPreviewsSheet: some View {
        let doneNavItem = Button("Done", action: donePreviewRelationships)
        return NavigationView {
            NoteCardScrollView(
                noteCards: relationshipNoteCards,
                onTap: { print($0.native) },
                showQuickButtons: false,
                searchModel: noteCardSearchModel
            )
                .navigationBarTitle("Relationships", displayMode: .inline)
                .navigationBarItems(leading: doneNavItem)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Action that goes in the quick button
    func beginPreviewRelationships() {
        relationshipNoteCards = noteCard.relationships.sorted(by: { $0.translation < $1.translation })
        noteCardSearchModel.context = noteCardDataSource.updateContext
        noteCardSearchModel.noteCardSearchOption = .include(relationshipNoteCards)
        sheet = .relationship
    }
    
    func donePreviewRelationships() {
        relationshipNoteCards = []
        noteCardSearchModel.deactivate()
        noteCardSearchModel.context = nil
        noteCardSearchModel.noteCardSearchOption = nil
        sheet = nil
    }
}


// MARK: - Tag Preview Sheet

extension NoteCardCollectionViewCard {
    
    /// A sheet that previews the tags of the selected card.
    var tagPreviewSheet: some View {
        EmptyView()
    }
    
    // Action that goes in the quick button
    func beginPreviewTags() {
        sheet = .tag
    }
    
    func donePreviewTags() {
        sheet = nil
    }
}


// MARK: - Note Preview Sheet

extension NoteCardCollectionViewCard {
    
    /// A sheet that previews note of the selected card.
    // Use NoteCardRelationshipView
    var notePreviewSheet: some View {
        EmptyView()
    }
    
    // Action that goes in the quick button
    func beginPreviewNote() {
        sheet = .relationship
    }
    
    func donePreviewNote() {
        sheet = nil
    }
}


// MARK: - Sheets

extension NoteCardCollectionViewCard {
    
    enum Sheet: Identifiable {
        case relationship
        case tag
        case note
        
        var id: Sheet { self }
    }
    
    func previewSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .relationship:
            return relationshipPreviewsSheet.eraseToAnyView()
        case .tag:
            return tagPreviewSheet.eraseToAnyView()
        case .note:
            return notePreviewSheet.eraseToAnyView()
        }
    }
    
    var dismissSheet: () -> Void {
        switch sheet {
        case .relationship:
            return donePreviewRelationships
        case .tag:
            return donePreviewTags
        case .note:
            return donePreviewNote
        case nil:
            return {}
        }
    }
}



struct NoteCardCollectionViewCard_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionViewCard(noteCard: .init())
    }
}
