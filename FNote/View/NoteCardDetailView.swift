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
    
    /// An action to perform when delete button is tapped.
    ///
    /// The delete button is hidden if this value is `nil`.
    var onDelete: (() -> Void)?
    
    /// A flag to control note model text field keyboard.
    @State private var isNoteEditingActive = true
    
    /// A sheet to indicate when presentation sheet to show.
    @State private var sheet: Sheet?
    
    @State private var showDeleteAlert = false
    
    @State private var showNotePreviewActionSheet = false
    
    let imageSize: CGFloat = 20
    
    
    // MARK: Body
    
    var body: some View {
        Form {
            nativeTranslationSection
            detailSection
            notePreviewSection
            actionSection
        }
        .sheet(item: $sheet, onDismiss: dismissSheet, content: presentationSheet)
        .alert(isPresented: $showDeleteAlert, content: deleteAlert)
    }
}


// MARK: - Native & Translation Section

extension NoteCardDetailView {
    
    var nativeTranslationSection: some View {
        Section(header: Text("NATIVE & TRANSLATION").padding(.top, 20)) {
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
    
    var detailSection: some View {
        Section(header: Text("RELATIONSHIPS & TAGS")) {
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
            
            // MARK: Relationship
            Button(action: beginEditingRelationship) {
                HStack {
                    Image.noteCardRelationship
                        .frame(width: imageSize, height: imageSize, alignment: .center)
                        .foregroundColor(.primary)
                    Text("Relationships")
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
            
            // MARK: Note
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


// MARK: Note Preview Section

extension NoteCardDetailView {
    
    var notePreviewSection: some View {
        let header = Text("NOTE PREVIEW")
        let footer = Text("Long press on the note to copy to clipboard")
        let note = noteCard.note.isEmpty ? " ᐧ  ᐧ  ᐧ" : noteCard.note
        return Section(header: header, footer: footer) {
            VStack {
                Text(note)
                    .foregroundColor(noteCard.note.isEmpty ? .secondary : .primary)
            }
            .frame(maxWidth: .infinity, minHeight: 0, alignment: .leading)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture(perform: beginEditingNote)
            .onLongPressGesture(perform: { self.showNotePreviewActionSheet = true })
            .actionSheet(isPresented: $showNotePreviewActionSheet, content: notePreviewActionSheet)
        }
    }
    
    func notePreviewActionSheet() -> ActionSheet {
        let copy = ActionSheet.Button.default(Text("Copy to Clipboard"), action: copyNoteToClipboard)
        let cancel = ActionSheet.Button.cancel()
        let title = Text("Note Action")
        return ActionSheet(title: title, message: nil, buttons: [copy, cancel])
    }
    
    func copyNoteToClipboard() {
        guard !noteCard.note.isEmpty else { return }
        UIPasteboard.general.string = noteCard.note
    }
}


// MARK: - Action Section

extension NoteCardDetailView {
    
    var actionSection: some View {
        Section {
            Button(action: { self.showDeleteAlert = true }) {
                Text("Delete")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .hidden(onDelete == nil)
        }
    }
}


// MARK: - Relationship Sheet

extension NoteCardDetailView {
    
    // View that uses the NoteCardRelationshipView
    var relationshipEditingSheet: some View {
        NoteCardRelationshipView(noteCard: noteCard, onDone: doneEditingRelationship)
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
        NoteCardTagView(noteCard: noteCard, onDone: doneEditingTag)
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
            isActive: $isNoteEditingActive,
            text: $noteCard.note,
            prompt: "Note",
            onCommit: commitEditingNote
        )
    }
    
    var emptyNotePlaceholderText: some View {
        Text(noteCard.note.isEmpty ? ". . ." : "")
            .font(.body)
            .padding(6)
            .foregroundColor(.secondary)
    }
    
    func rowImage(systemName: String) -> some View {
        Image(systemName: systemName)
            .frame(minWidth: 20, maxWidth: 20, alignment: .center)
    }
    
    func beginEditingNote() {
        isNoteEditingActive = true
        sheet = .note
    }
    
    func commitEditingNote() {
        noteCard.note = noteCard.note.trimmed()
        isNoteEditingActive = false
        sheet = nil
    }
}


// MARK: - Presentation Sheet

extension NoteCardDetailView {
    
    enum Sheet: Identifiable {
        case relationship
        case tag
        case note
        
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
        case nil:
            return {}
        }
    }
}


// MARK: - Alert

extension NoteCardDetailView {
    
    func deleteAlert() -> Alert {
        let collectionName = "'\(noteCard.collection!.name)'"
        let title = Text("Delete Note Card")
        let message = Text("Delete note card from the \(collectionName) collection.")
        let delete = Alert.Button.destructive(Text("Delete"), action: onDelete)
        return Alert(title: title, message: message, primaryButton: .cancel(), secondaryButton: delete)
    }
}


struct NoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardDetailView(noteCard: .init())
    }
}
