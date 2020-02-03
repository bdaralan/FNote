//
//  NoteCardForm.swift
//  FNote
//
//  Created by Dara Beng on 2/2/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardForm: View {
    
    @ObservedObject var viewModel: NoteCardFormModel
    
    @State private var sheet: Sheet?
    @State private var modalTextViewModel = ModalTextViewModel()
    
    @State private var collectionViewModel = NoteCardCollectionCollectionViewModel()
    @State private var relationshipViewModel = NoteCardCollectionViewModel()
    @State private var tagViewModel = TagCollectionViewModel()
    
    @State private var translationTextField: UITextField?
    
    let iconSize = CGSize(width: 25, height: 20)
    
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 32) {
                    // MARK: Native & Translation
                    VStack(spacing: 5) {
                        TextFieldWrapper(
                            isActive: $viewModel.isNativeFirstResponder,
                            text: $viewModel.native,
                            placeholder: viewModel.nativePlaceholder,
                            nextResponder: translationTextField,
                            configure: configureNativeTextField
                        )
                            .modifier(NoteCardFormRowModifier())
                        
                        TextFieldWrapper(
                            isActive: $viewModel.isTranslationFirstResponder,
                            text: $viewModel.translation,
                            placeholder: viewModel.translationPlaceholder,
                            onCommit: nil,
                            configure: configureTranslationTextField
                        )
                            .modifier(NoteCardFormRowModifier())
                    }
                    .modifier(NoteCardFormSectionModifier(header: "NATIVE & TRANSLATION"))
                    
                    // MARK: Collection
                    VStack {
                        HStack {
                            Text(viewModel.selectedCollection?.name ?? "None")
                                .foregroundColor(viewModel.selectedCollection == nil ? .secondary : .primary)
                            Spacer()
                            HStack {
                                Text("4 CARDS")
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                        }
                        .modifier(NoteCardFormRowModifier())
                        .onTapGesture(perform: beginSelectCollection)
                        .onReceive(viewModel.$isSelectingCollection, perform: handleOnReceiveSelectingCollection)
                        .background(
                            NavigationLink(
                                destination: NoteCardFormCollectionSelectionView(viewModel: collectionViewModel),
                                isActive: $viewModel.isSelectingCollection,
                                label: EmptyView.init
                            )
                        )
                    }
                    .modifier(NoteCardFormSectionModifier(header: "COLLECTION"))
                    
                    // MARK: Formality
                    VStack {
                        SegmentControlWrapper(
                            selectedIndex: $viewModel.formality,
                            segments: viewModel.formalities,
                            selectedColor: viewModel.selectedFormality.uiColor
                        )
                            .modifier(NoteCardFormRowModifier())
                    }
                    .modifier(NoteCardFormSectionModifier(header: "FORMALITY"))
                    
                    // MARK: Favorite
                    VStack(spacing: 5) {
                        Toggle(isOn: $viewModel.isFavorite) {
                            Image.noteCardFavorite(viewModel.isFavorite)
                                .frame(width: iconSize.width, height: iconSize.height, alignment: .center)
                            Text("Favorite")
                                .padding(.leading, 4)
                        }
                        .modifier(NoteCardFormRowModifier())
                        
                        // MARK: Relationship
                        HStack {
                            Image.noteCardRelationship
                                .frame(width: iconSize.width, height: iconSize.height, alignment: .center)
                                .foregroundColor(.primary)
                            Text("Links")
                                .foregroundColor(.primary)
                                .padding(.leading, 4)
                            Spacer()
                            HStack {
                                Text("\(viewModel.selectedRelationships.count)")
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                        }
                        .modifier(NoteCardFormRowModifier())
                        .onTapGesture(perform: beginSelectRelationship)
                        .onReceive(viewModel.$isSelectingRelationship, perform: handleOnReceiveSelectingRelationship)
                        .background(
                            NavigationLink(
                                destination: NoteCardFormRelationshipSelectionView(viewModel: relationshipViewModel),
                                isActive: $viewModel.isSelectingRelationship,
                                label: EmptyView.init
                            )
                        )
                        
                        // MARK: Tag
                        HStack {
                            Image.noteCardTag
                                .frame(width: iconSize.width, height: iconSize.height, alignment: .center)
                                .foregroundColor(.primary)
                            Text("Tags")
                                .foregroundColor(.primary)
                                .padding(.leading, 4)
                            Spacer()
                            HStack {
                                Text("\(viewModel.selectedTags.count)")
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(.tertiaryLabel))
                            }
                        }
                        .modifier(NoteCardFormRowModifier())
                        .onTapGesture(perform: beginSelectTag)
                        .onReceive(viewModel.$isSelectingTag, perform: handleOnReceiveSelectingTag)
                        .background(
                            NavigationLink(
                                destination: NoteCardFormTagSelectionView(viewModel: tagViewModel, onCreateTag: handleCreateTag),
                                isActive: $viewModel.isSelectingTag,
                                label: EmptyView.init
                            )
                        )
                        
                        // MARK: Note
                        HStack {
                            Image.noteCardNote
                                .frame(width: iconSize.width, height: iconSize.height, alignment: .center)
                                .foregroundColor(.primary)
                            Text("Note")
                                .foregroundColor(.primary)
                                .padding(.leading, 4)
                            Spacer()
                            HStack(spacing: 3) { // markdown logo with sf symbol
                                Image(systemName: "m.square")
                                Image(systemName: "arrow.down.square")
                            }
                            .foregroundColor(.secondary)
                        }
                        .modifier(NoteCardFormRowModifier())
                        .onTapGesture(perform: beginEditNote)
                    }
                }
                .padding(.vertical, 32)
            }
            .navigationBarItems(leading: cancelNavItem, trailing: commitNavItem)
            .navigationBarTitle(Text(viewModel.navigationTitle), displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet, onDismiss: handleSheetDismissed, content: presentationSheet)
    }
}


// MARK: - Navigation Items

extension NoteCardForm {
    
    var cancelNavItem: some View {
        Button("Cancel", action: viewModel.onCancel ?? {})
            .disabled(viewModel.onCancel == nil)
    }
    
    var commitNavItem: some View {
        Button(action: viewModel.onCommit ?? {}) {
            Text(viewModel.commitTitle).bold()
        }
        .disabled(viewModel.onCommit == nil || !viewModel.canCommit)
    }
}


// MARK: - Sheet

extension NoteCardForm {
    
    enum Sheet: Identifiable {
        var id: Self { self }
        case note
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .note:
            return ModalTextView(viewModel: $modalTextViewModel)
        }
    }
    
    func handleSheetDismissed() {
        if modalTextViewModel.onCommit != nil {
            viewModel.note = modalTextViewModel.text
        }
    }
}


// MARK: - Note

extension NoteCardForm {
    
    func beginEditNote() {
        modalTextViewModel.title = "Note"
        modalTextViewModel.text = viewModel.note
        
        modalTextViewModel.isFirstResponder = true
        modalTextViewModel.onCommit = commitEditNote
        
        sheet = .note
    }
    
    func commitEditNote() {
        viewModel.note = modalTextViewModel.text
        sheet = nil
    }
}


// MARK: - Collection Selection

extension NoteCardForm {
    
    func beginSelectCollection() {
        collectionViewModel.collections = viewModel.selectableCollections
        collectionViewModel.onCollectionSelected = handleNoteCardCollectionSelected
        
        if let collection = viewModel.selectedCollection {
            collectionViewModel.disableCollectionIDs = [collection.uuid]
        }
        
        viewModel.isSelectingCollection = true
    }
    
    func handleOnReceiveSelectingCollection(_ isSelecting: Bool) {
        guard !isSelecting else { return }
        collectionViewModel = .init()
    }
    
    func handleNoteCardCollectionSelected(_ collection: NoteCardCollection) {
        viewModel.selectedCollection = collection
        viewModel.isSelectingCollection = false
    }
}


// MARK: - Relationship Selection

extension NoteCardForm {
    
    func beginSelectRelationship() {
        relationshipViewModel.noteCards = viewModel.selectableRelationships
        relationshipViewModel.cellStyle = .short
        
        viewModel.selectedRelationships.forEach { noteCard in
            relationshipViewModel.borderedNoteCardIDs.insert(noteCard.uuid)
        }
        
        if let noteCard = viewModel.selectedNoteCard {
            relationshipViewModel.disableNoteCardIDs.insert(noteCard.uuid)
        }
        
        relationshipViewModel.onNoteCardSelected = handleRelationshipNoteCardSelected
        
        viewModel.isSelectingRelationship = true
    }
    
    func handleOnReceiveSelectingRelationship(_ isSelecting: Bool) {
        guard !isSelecting else { return }
        relationshipViewModel = .init()
    }
    
    func handleRelationshipNoteCardSelected(_ noteCard: NoteCard) {
        if relationshipViewModel.borderedNoteCardIDs.contains(noteCard.uuid) {
            relationshipViewModel.borderedNoteCardIDs.remove(noteCard.uuid)
        } else {
            relationshipViewModel.borderedNoteCardIDs.insert(noteCard.uuid)
        }
        viewModel.onRelationshipSelected?(noteCard)
    }
}


// MARK: - Tag Selection

extension NoteCardForm {
    
    func beginSelectTag() {
        tagViewModel.tags = viewModel.selectableTags
        
        for tag in viewModel.selectedTags {
            tagViewModel.borderedTagIDs.insert(tag.uuid)
        }
        
        tagViewModel.onTagSelected = handleTagViewTagSelected
        
        viewModel.isSelectingTag = true
    }
    
    func handleOnReceiveSelectingTag(_ isSelecting: Bool) {
        guard !isSelecting else { return }
        tagViewModel = .init()
    }
    
    func handleTagViewTagSelected(_ tag: Tag) {
        if tagViewModel.borderedTagIDs.contains(tag.uuid) {
            tagViewModel.borderedTagIDs.remove(tag.uuid)
        } else {
            tagViewModel.borderedTagIDs.insert(tag.uuid)
        }
        viewModel.onTagSelected?(tag)
    }
    
    func handleCreateTag(withName name: String) -> Bool {
        if let tag = viewModel.onCreateTag?(name) {
            tagViewModel.tags.insert(tag, at: 0)
            tagViewModel.borderedTagIDs.insert(tag.uuid)
            tagViewModel.updateSnapshot(animated: true)
            return true
        }
        return false
    }
}


// MARK: - Setup Text Field

extension NoteCardForm {
    
    func configureNativeTextField(_ textField: UITextField) {
        textField.font = .preferredFont(forTextStyle: .headline)
        textField.returnKeyType = .next
    }
    
    func configureTranslationTextField(_ textField: UITextField) {
        translationTextField = textField
        textField.font = .preferredFont(forTextStyle: .body)
    }
}


struct NoteCardForm_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NoteCardForm(viewModel: .init()).colorScheme(.light)
            NoteCardForm(viewModel: .init()).colorScheme(.dark)
        }
    }
}
