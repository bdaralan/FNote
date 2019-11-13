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
    
    var showQuickButton: Bool = true
    
    var cardBackground: Color?
    
    var onRelationshipTapped: (() -> Void)?
    
    /// An action to perform when the done button is pressed
    var onDone: (() -> Void)?
    
    var onTagTapped: (() -> Void)?
    
    var onFormalityTapped: (() -> Void)?
    
    @ObservedObject private var viewReloader = ViewForceReloader()
    
    /// A view model used to handle search.
    @State private var  noteCardSearchModel = NoteCardSearchModel()
    
    @State private var sheet: Sheet?
    
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
        .sheet(item: $sheet, onDismiss: dismissSheet, content: previewSheet)
    }
}


extension NoteCardCollectionViewCard {
    
    func relationshipButton() -> some View {
        Button(action: beginPreviewRelationships ) {
            HStack {
                Image.noteCardRelationship
                Text("\(noteCard.relationships.count)")
                    .font(.body)
            }
            .foregroundColor(.primary)
        }
    }
    
    func tagButton() -> some View {
        Button(action: onTagTapped ?? {}) {
            HStack {
                Image.noteCardTag
                Text("\(noteCard.tags.count)")
            }
            .font(.body)
            .foregroundColor(.primary)
        }
    }
    
    func formalButton() -> some View {
        Button(action: onFormalityTapped ?? {}) {
            HStack {
                Image.noteCardFormality
                Text(noteCard.formality == .notset ? " " : noteCard.formality.abbreviation)
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


// MARK: - Button Sheets

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
            return relationshipPreviewSheet
                .eraseToAnyView()
        
        case .tag:
            return tagPreviewSheet
                .eraseToAnyView()
            
        case .note:
            return notePreviewSheet
                .eraseToAnyView()
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

// MARK: - Relationships Preview Sheet

extension NoteCardCollectionViewCard {
    
    /// The note cards to display.
    var noteCards: [NoteCard] {
        if noteCardSearchModel.isActive {
            return noteCardSearchModel.searchFetchResult?.fetchedObjects ?? []
        } else {
            return Array(noteCard.relationships)
        }
    }
    /// A sheet that previews the related cards of the selected card.
    // Use NoteCardRelationshipView
    var relationshipPreviewSheet: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchTextField(
                    searchField: noteCardSearchModel.searchField,
                    searchOption: noteCardSearchModel.searchOption,
                    onCancel: noteCardSearchModel.deactivate
                )
                    .onReceive(noteCardSearchModel.objectWillChange, perform: viewReloader.forceReload)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                
                NoteCardScrollView(noteCards: noteCards, showQuickButton: false)
            }
            .navigationBarTitle("Relationships", displayMode: .inline)
            .navigationBarItems(leading: doneNavItem, trailing: searchNavItem)
            .onAppear(perform: setupView)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Button to show the add relationship sheet
    var searchNavItem: some View {
        Button(action: {}) {
            Image(systemName: "magnifyingglass")
                .imageScale(.large)
        }
    }
    
    var doneNavItem: some View {
        Button(action: donePreviewRelationships) {
            Text("Done")
        }
    }
    
    // Action that goes in the quick button
    func beginPreviewRelationships() {
        sheet = .relationship
    }
    
    func donePreviewRelationships() {
        sheet = nil
        onDone?()
    }
    
    func setupView() {
        noteCardSearchModel.context = noteCardDataSource.updateContext
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


// MARK: - Formality Preview Sheet

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
struct NoteCardCollectionViewCard_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardCollectionViewCard(noteCard: .init())
    }
}
