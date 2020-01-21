//
//  NoteCardDetailView.swift
//  FNote
//
//  Created by Dara Beng on 9/11/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardDetailView: View {
    
    @EnvironmentObject var noteCardDataSource: NoteCardDataSource
    
    @EnvironmentObject var tagDataSource: TagDataSource
    
    @ObservedObject var noteCard: NoteCard
    
    /// A collection to assign to `noteCard`.
    ///
    /// - Important:
    ///   - Should only use this property when creating a new note card.
    ///   - Set this property will add change-collection section to the form.
    @Binding var collectionToAssign: NoteCardCollection?
    
    /// A string used to hold note card's note with model text view.
    @State private var noteCardNote = ""
    
    /// A flag to control note model text field keyboard.
    @State private var isNoteTextViewFirstResponder = true
    
    /// A sheet to indicate when presentation sheet to show.
    @State private var sheet: Sheet?
        
    let imageSize: CGFloat = 20
    
    
    // MARK: Body
    
    var body: some View {
        Form {
            if collectionToAssign != nil {
                changeCollectionSection
            }
            nativeTranslationSection
            formalityFavoriteSection
            linkTagSection
            noteSection
        }
        .sheet(item: $sheet, onDismiss: dismissSheet, content: presentationSheet)
    }
}


// MARK: - Collection Selection Section

extension NoteCardDetailView {
    
    var changeCollectionSection: some View {
        let collectionName = collectionToAssign?.name ?? "???"
        let cardCount = collectionToAssign?.noteCards.count ?? 0
        let plural = cardCount == 1 ? "" : "S"
        
        return Section(header: Text("COLLECTION").padding(.top, 24)) {
            Button(action: beginChangeCollection) {
                HStack {
                    Text(collectionName)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(cardCount) CARD\(plural)")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}


// MARK: - Native & Translation Section

extension NoteCardDetailView {
    
    var nativeTranslationSection: some View {
        Section(header: Text("NATIVE & TRANSLATION").padding(.top, collectionToAssign == nil ? 24 : 0)) {
            VStack(alignment: .leading, spacing: 2) {
                TextField("Native", text: $noteCard.native)
                    .font(.title)
                Text("Native")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                TextField("Translation", text: $noteCard.translation)
                    .font(.title)
                Text("Translation")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}


// MARK: - Detail Section

extension NoteCardDetailView {
    
    var formalityFavoriteSection: some View {
        Section(header: Text("FORMALITY & FAVORITE")) {
            // MARK: Formality
            HStack {
                Image.noteCardFormality
                    .frame(width: imageSize, height: imageSize, alignment: .center)
                    .foregroundColor(noteCard.formality.color)
                Picker("", selection: $noteCard.formality) {
                    ForEach(NoteCard.Formality.allCases, id: \.self) { formality in
                        Text(formality.title).tag(formality)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // MARK: Favorite
            Toggle(isOn: $noteCard.isFavorited) {
                Image.noteCardFavorite(noteCard.isFavorited)
                    .frame(width: imageSize, height: imageSize, alignment: .center)
                Text("Favorite")
            }
        }
    }
    
    var linkTagSection: some View {
        Section(header: Text("LINKS & TAGS")) {
            // MARK: Relationship
            Button(action: beginEditingRelationship) {
                HStack {
                    Image.noteCardRelationship
                        .frame(width: imageSize, height: imageSize, alignment: .center)
                        .foregroundColor(.primary)
                    Text("Links")
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(noteCard.relationships.count)")
                        .foregroundColor(.secondary)
                }
            }
            
            // MARK: Tag
            Button(action: beginEditingTag) {
                HStack {
                    Image.noteCardTag
                        .frame(width: imageSize, height: imageSize, alignment: .center)
                        .foregroundColor(.primary)
                    Text("Tags")
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(noteCard.tags.count)")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    var noteSection: some View {
        // MARK: Note
        let header = Text("NOTE")
        let footer = Text("Supports simple Markdown markup language features such as headings, emphasis, lists, and hyperlinks.\n")
        return Section(header: header, footer: footer) {
            Button(action: beginEditingNote) {
                HStack {
                    Image.noteCardNote
                        .frame(width: imageSize, height: imageSize, alignment: .center)
                        .foregroundColor(.primary)
                    Text("Note")
                        .foregroundColor(.primary)
                    Spacer()
                    HStack(spacing: 3) { // markdown logo with sf symbol
                        Image(systemName: "m.square")
                        Image(systemName: "arrow.down.square")
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
}


// MARK: - Choose Collection Sheet

extension NoteCardDetailView {
    
    var changeCollectionSheet: some View {
        let context = noteCard.managedObjectContext!
        let collections = try? context.fetch(NoteCardCollection.requestAllCollections())
        let disableCollections = collectionToAssign != nil ? [collectionToAssign!] : []
        return NoteCardCollectionSelectionView(
            title: "Choose Collection",
            collections: collections ?? [],
            disableCollections: disableCollections,
            onSelected: commitChangeCollection,
            onDone: dismissSheet
        )
    }
    
    func beginChangeCollection() {
        sheet = .changeCollection
    }
    
    func commitChangeCollection(_ collection: NoteCardCollection) {
        collectionToAssign = collection
        sheet = nil
    }
    
    func dismissChangeCollectionSheet() {
        sheet = nil
    }
}


// MARK: - Relationship Sheet

extension NoteCardDetailView {
    
    // View that uses the NoteCardRelationshipView
    var relationshipEditingSheet: some View {
        NoteCardDetailRelationshipView(noteCard: noteCard, onDone: doneEditingRelationship)
            .environmentObject(noteCardDataSource) // use the noteCardDataSource as the environment object
    }
    
    func beginEditingRelationship() {
        sheet = .relationship
    }
    
    func doneEditingRelationship() {
        sheet = nil
    }
}


// MARK: - Tag Sheet

extension NoteCardDetailView {
    
    var tagEditingSheet: some View {
        NoteCardDetailTagView(noteCard: noteCard, onDone: doneEditingTag)
    }
    
    func beginEditingTag() {
        sheet = .tag
    }
    
    func doneEditingTag() {
        sheet = nil
    }
}


// MARK: - Note Sheet

extension NoteCardDetailView {
    
    var noteEditingSheet: some View {
        ModalTextView(
            title: "Note",
            text: $noteCardNote,
            isFirstResponder: $isNoteTextViewFirstResponder,
            onDone: commitEditingNote
        )
    }
    
    func rowImage(systemName: String) -> some View {
        Image(systemName: systemName)
            .frame(minWidth: 20, maxWidth: 20, alignment: .center)
    }
    
    func beginEditingNote() {
        noteCardNote = noteCard.note
        isNoteTextViewFirstResponder = true
        sheet = .note
    }
    
    func commitEditingNote() {
        noteCard.note = noteCardNote.trimmed()
        isNoteTextViewFirstResponder = false
        sheet = nil
    }
}


// MARK: - Presentation Sheet

extension NoteCardDetailView {
    
    enum Sheet: Identifiable {
        case relationship
        case tag
        case note
        case changeCollection
        
        var id: Sheet { self }
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        
        case .relationship:
            return relationshipEditingSheet
                .eraseToAnyView()
        
        case .tag:
            return tagEditingSheet
                .environmentObject(tagDataSource)
                .eraseToAnyView()
        
        case .note:
            return noteEditingSheet
                .eraseToAnyView()
            
        case .changeCollection:
            return changeCollectionSheet
                .eraseToAnyView()
        }
    }
    
    var dismissSheet: () -> Void {
        switch sheet {
        case .relationship:
            return doneEditingRelationship
        case .tag:
            return doneEditingTag
        case .note:
            return commitEditingNote
        case .changeCollection:
            return dismissChangeCollectionSheet
        case nil:
            return {}
        }
    }
}


// MARK: - Setup

extension NoteCardDetailView {
    
    func setupNativeTranslationTextField(_ textField: UITextField) {
        textField.font = .preferredFont(forTextStyle: .title1)
    }
}


struct NoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardDetailView(noteCard: .init(), collectionToAssign: .constant(nil))
    }
}
