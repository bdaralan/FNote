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
    
    @State private var isEditingNote = false
    
    
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
                Button(action: { self.isEditingNote = true }) {
                    TextField("note...", text: $noteCard.note)
                }
            }
        }
        .sheet(isPresented: $isEditingNote, onDismiss: nil) {
            ModalTextField(
                isActive: self.$isEditingNote,
                text: self.$noteCard.navtive,
                prompt: "Prompt",
                placeholder: "Placeholder",
                description: "This is a tip text",
                onCommit: { self.isEditingNote = false }
            )
        }
    }
}


extension NoteCardView {
    
    var formalityPickerLabel: some View {
        ViewBuilder.buildBlock(rowImage(systemName: "hand.raised.fill"), Text("Formality"))
    }
    
    func rowImage(systemName: String) -> some View {
        Image(systemName: systemName)
            .frame(minWidth: 20, maxWidth: 20, alignment: .center)
    }
}


struct NoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardView()
    }
}
