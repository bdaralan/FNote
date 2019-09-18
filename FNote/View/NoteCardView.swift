//
//  NoteCardView.swift
//  FNote
//
//  Created by Dara Beng on 9/11/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardView: View {
    
    @ObservedObject var noteCard = NoteCard.sampleNoteCards(count: 1)[0]
    
    /// Used to get new input for `noteCard`'s note.
    @State private var noteCardNote = ""
    
    @State private var showNoteEditingSheet = false
    
    
    var body: some View {
        Form {
            Section(header: Text("NATIVE & TRANSLATION").padding(.top, 20)) {
                VStack(alignment: .leading, spacing: 2) {
                    TextField("Native", text: $noteCard.navtive)
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
            
            Section(header: Text("RELATIONSHIP & TAG")) {
                Toggle(isOn: $noteCard.isFavorited) {
                    rowImage(systemName: "star.fill")
                    Text("Favorite")
                }
                Picker(selection: $noteCard.formality, label: formalityPickerLabel) {
                    ForEach(NoteCard.Formality.allCases, id: \.self) { formality in
                        Text(formality.title).tag(formality)
                    }
                }
                NavigationLink(destination: Text("Relationship")) {
                    rowImage(systemName: "link.circle.fill")
                    Text("Relationship")
                }
                NavigationLink(destination: Text("Tag")) {
                    rowImage(systemName: "tag.fill")
                    Text("Tag")
                }
            }
            
            Section(header: Text("NOTE")) {
                NoteCardNoteTextViewWrapper(text: $noteCard.note)
                    .frame(minHeight: 250, maxHeight: .infinity, alignment: .center)
                    .padding(0)
                    .overlay(emptyNotePlaceholderText, alignment: .topLeading)
                    .onTapGesture(perform: beginEditingNoteCardNote)
            }
        }
        .sheet(isPresented: $showNoteEditingSheet, content: { self.noteEditingSheet })
    }
}


extension NoteCardView {
    
    var noteEditingSheet: some View {
        ModalTextView(
            isActive: $showNoteEditingSheet,
            text: $noteCardNote,
            prompt: "Note",
            onCommit: commitEditingNoteCardNote
        )
    }
    
    var emptyNotePlaceholderText: some View {
        Text(noteCard.note.isEmpty ? ". . ." : "")
            .font(.body)
            .padding(6)
            .foregroundColor(.secondary)
    }
    
    var formalityPickerLabel: some View {
        ViewBuilder.buildBlock(rowImage(systemName: "hand.raised.fill"), Text("Formality"))
    }
    
    func rowImage(systemName: String) -> some View {
        Image(systemName: systemName)
            .frame(minWidth: 20, maxWidth: 20, alignment: .center)
    }
    
    func beginEditingNoteCardNote() {
        noteCardNote = noteCard.note
        showNoteEditingSheet = true
    }
    
    func commitEditingNoteCardNote() {
        noteCard.note = noteCardNote
        noteCardNote = ""
        showNoteEditingSheet = false
    }
}


struct NoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardView()
    }
}
