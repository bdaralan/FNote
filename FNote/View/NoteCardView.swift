//
//  NoteCardView.swift
//  FNote
//
//  Created by Dara Beng on 9/11/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardView: View {
    
    @EnvironmentObject var tagDataSource: TagDataSource
    
    @ObservedObject var noteCard: NoteCard
    
    /// Used to get new input for `noteCard`'s note.
    @State private var noteCardNote = ""
    
    @State private var showNoteEditingSheet = false
    
    @State private var addedTags = [TagViewModel]()
    
    @State private var availableTags = [TagViewModel]()
    
    
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
                NavigationLink(destination: addTagView) {
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


extension NoteCardView {
    
    var addTagView: some View {
        NoteCardAddTagView(
            addedTags: $addedTags,
            addableTags: $availableTags,
            onTagAdd: addTagToNoteCard,
            onTagRemove: removeTagFromNoteCard,
            onTagCreate: addNewTagToNoteCard
        )
            .onAppear {
                let allTags = self.tagDataSource.fetchedResult.fetchedObjects ?? []
                let addedTags = self.noteCard.tags.map({ TagViewModel(tag: $0) })
                let availableTags = allTags.compactMap { tag -> TagViewModel? in
                    let tagModel = TagViewModel(tag: tag)
                    guard !addedTags.contains(tagModel) else { return nil }
                    return tagModel
                }
                
                self.addedTags = addedTags
                self.availableTags = availableTags
        }
    }
    
    func addTagToNoteCard(_ tag: TagViewModel) {
        guard !addedTags.contains(tag), let index = availableTags.firstIndex(of: tag) else { return }
        // update UI property
        addedTags.append(tag)
        addedTags.sortByName()
        availableTags.remove(at: index)
        
        // add tag to note card
        let allTags = tagDataSource.fetchedResult.fetchedObjects ?? []
        guard let tagToAdd = allTags.first(where: { $0.uuid == tag.uuid }) else { return }
        let tagToAddFromSameContext = tagToAdd.get(from: noteCard.managedObjectContext!)
        noteCard.tags.insert(tagToAddFromSameContext)
    }
    
    func removeTagFromNoteCard(_ tag: TagViewModel) {
        guard !availableTags.contains(tag), let index = addedTags.firstIndex(of: tag) else { return }
        availableTags.append(tag)
        availableTags.sortByName()
        addedTags.remove(at: index)
        
        guard let tagToRemove = noteCard.tags.first(where: { $0.uuid == tag.uuid }) else { return }
        let tagToRemoveFromSameContext = tagToRemove.get(from: noteCard.managedObjectContext!)
        noteCard.tags.remove(tagToRemoveFromSameContext)
    }
    
    func addNewTagToNoteCard(_ tag: TagViewModel) {
        let newTag = Tag(context: noteCard.managedObjectContext!)
        newTag.name = tag.name
        noteCard.tags.insert(newTag)
        
        let tagModel = TagViewModel(tag: newTag)
        availableTags.append(tagModel)
        availableTags.sortByName()
    }
}


struct NoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardView(noteCard: .init())
    }
}


func addToSelectedTags(_ tag: TagViewModel) {
    
    
}

func removeFromSelectedTags(_ tag: TagViewModel) {
    
    
}
