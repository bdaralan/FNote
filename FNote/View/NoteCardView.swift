//
//  NoteCardView.swift
//  FNote
//
//  Created by Dara Beng on 9/11/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct NoteCardView: View {
    
    @EnvironmentObject var noteCardDataSource: NoteCardDataSource
    
    @EnvironmentObject var tagDataSource: TagDataSource
    
    @ObservedObject var noteCard: NoteCard
    
    var onDelete: (() -> Void)?
    
    @State private var addTagViewModel = NoteCardAddTagViewModel()
    
    /// Used to get new input for `noteCard`'s note.
    @State private var noteCardNote = ""
    
    @State private var showNoteEditingSheet = false
    
    @State private var showAddNoteCardRelationshipSheet = false
    
    let imageSize: CGFloat = 20
    
    
    // MARK: Body
    
    var body: some View {
        Form {
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
            
            Section(header: Text("RELATIONSHIP & TAG")) {
                Toggle(isOn: $noteCard.isFavorited) {
                    Image.noteCardFavorite(noteCard.isFavorited)
                        .frame(width: imageSize, height: imageSize, alignment: .center)
                    Text("Favorite")
                }
                
                Picker(selection: $noteCard.formality, label: Group {
                    Image.noteCardFormality
                        .frame(width: imageSize, height: imageSize, alignment: .center)
                    Text("Formality")
                }) {
                    ForEach(NoteCard.Formality.allCases, id: \.self) { formality in
                        Text(formality.title).tag(formality)
                    }
                }
                
                NavigationLink(destination: noteCardRelationshipView) {
                    Image.noteCardRelationship
                        .frame(width: imageSize, height: imageSize, alignment: .center)
                    Text("Relationship")
                    
                }
                
                NavigationLink(destination: addTagView) {
                    Image.noteCardTag
                        .frame(width: imageSize, height: imageSize, alignment: .center)
                    Text("Tags")
                }
            }
            
            Section(header: Text("NOTE")) {
                NoteCardNoteTextViewWrapper(text: $noteCard.note)
                    .frame(minHeight: 250, maxHeight: .infinity, alignment: .center)
                    .padding(0)
                    .overlay(emptyNotePlaceholderText, alignment: .topLeading)
                    .onTapGesture(perform: beginEditingNoteCardNote)
            }
            
            Section {
                Button(action: onDelete ?? {}) {
                    Text("Delete")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .hidden(onDelete == nil)
            }
        }
        .sheet(isPresented: $showNoteEditingSheet, content: { self.noteEditingSheet })
    }
}


extension NoteCardView {
    
    // MARK: Relationships
    
    // View that uses the NoteCardRelationshipView
    var noteCardRelationshipView: some View {
        NoteCardRelationshipView(noteCards: NoteCard.sampleNoteCards(count: 10))
        .navigationBarTitle("Relationships")
        .navigationBarItems(trailing: addRelationshipNavItem)
            .sheet(isPresented: $showAddNoteCardRelationshipSheet, onDismiss: nil, content: {self.addRelationshipCardView})
    }
    
    // Button to show the add relationship sheet
    var addRelationshipNavItem: some View {
        Button(action: beginAddRelationship) {
                Image(systemName: "plus")
                    .imageScale(.large)
        }
    }
    
    // View that lets the user add unrelated cards
    var addRelationshipCardView: some View {
        
        // Fetch all the notecards through the data source
        let allNoteCards = noteCardDataSource.fetchedResult.fetchedObjects ?? []
        
        // Filters allNoteCards to show unrelated cards by checking if it is in the relationship set
        let unrelatedNoteCards = allNoteCards.filter { noteCard in
            return !self.noteCard.relationships.contains(noteCard)
        }
        
        // Use NavigationView to allow user to cancel and add while in NoteCardRelationshipView
        return NavigationView {
            NoteCardRelationshipView(noteCards: unrelatedNoteCards, onLongPressed: nil, onDone: nil)
                .navigationBarTitle("Add Relationships", displayMode: .inline)
                .navigationBarItems(leading: Text("Cancel"), trailing: Text("Add"))
        }
    }
    
    // Change the boolean to true to display the sheet
    func beginAddRelationship() {
        showAddNoteCardRelationshipSheet = true
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
        showNoteEditingSheet = false
    }
}


extension NoteCardView {
    
    var addTagView: some View {
        NoteCardAddTagView(viewModel: $addTagViewModel)
            .onAppear(perform: prepareNoteCardAddTagViewModel)
    }
    
    func prepareNoteCardAddTagViewModel() {
        let allTags = tagDataSource.fetchedResult.fetchedObjects ?? []
        let includedTags = noteCard.tags.compactMap({ TagViewModel(tag: $0) })
        let excludedTags = allTags.compactMap { tag -> TagViewModel? in
            let tagModel = TagViewModel(tag: tag)
            guard !includedTags.contains(where: { $0.uuid == tagModel.uuid }) else { return nil }
            return tagModel
        }
        
        addTagViewModel.setTags(included: includedTags.sortedByName(), excluded: excludedTags.sortedByName())
        addTagViewModel.onTagIncluded = addTagToNoteCard
        addTagViewModel.onTagExcluded = removeTagFromNoteCard
        addTagViewModel.onTagUpdated = renameTag
        addTagViewModel.onTagCreated = addNewTagToNoteCard
    }
    
    func addNewTagToNoteCard(_ tag: TagViewModel) {
        let newTag = Tag(uuid: tag.uuid, context: noteCard.managedObjectContext!)
        newTag.name = tag.name
        noteCard.objectWillChange.send()
        noteCard.tags.insert(newTag)
    }
    
    func addTagToNoteCard(_ tag: TagViewModel) {
        let allTags = tagDataSource.fetchedResult.fetchedObjects ?? []
        guard let tagToAdd = allTags.first(where: { $0.uuid == tag.uuid }) else { return }
        let tagToAddFromSameContext = tagToAdd.get(from: noteCard.managedObjectContext!)
        noteCard.objectWillChange.send()
        noteCard.tags.insert(tagToAddFromSameContext)
    }
    
    func removeTagFromNoteCard(_ tag: TagViewModel) {
        guard let tagToRemove = noteCard.tags.first(where: { $0.uuid == tag.uuid }) else { return }
        let tagToRemoveInSameContext = tagToRemove.get(from: noteCard.managedObjectContext!)
        noteCard.objectWillChange.send()
        noteCard.tags.remove(tagToRemoveInSameContext)
    }
    
    func renameTag(_ tag: TagViewModel) {
        let allTags = tagDataSource.fetchedResult.fetchedObjects ?? []
        guard let tagToRename = allTags.first(where: { $0.uuid == tag.uuid }) else { return }
        let tagToRenameInSameContext = tagToRename.get(from: tagDataSource.updateContext)
        tagToRenameInSameContext.name = tag.name
    }
}


struct NoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardView(noteCard: .init())
    }
}
