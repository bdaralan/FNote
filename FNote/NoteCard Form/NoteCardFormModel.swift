//
//  NoteCardFormModel.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit
import CoreData


class NoteCardFormModel: ObservableObject {
    
    // MARK: Object Property
    @Published var native = ""
    @Published var translation = ""
    @Published var formality = 0
    @Published var isFavorite = false
    @Published var note = ""
    
    @Published var selectableCollections: [NoteCardCollection] = []
    @Published var selectableRelationships: [NoteCard] = []
    @Published var selectableTags: [Tag] = []
    
    @Published var selectedCollection: NoteCardCollection
    @Published var selectedRelationships: Set<NoteCard> = []
    @Published var selectedTags: Set<Tag> = []
    
    // MARK: Action
    var onTagSelected: ((Tag) -> Void)?
    var onCollectionSelected: ((NoteCardCollection) -> Void)?
    
    var onCancel: (() -> Void)?
    var onCommit: (() -> Void)?
    
    // MARK: UI Property
    
    /// Used to control NavigationLink
    @Published var isSelectingCollection = false
    
    /// Used to control NavigationLink
    @Published var isSelectingTag = false
    
    var canCommit: Bool {
        return !translation.trimmed().isEmpty
            && !native.trimmed().isEmpty
    }
    
    var nativePlaceholder = "안영"
    var translationPlaceholder = "Hi"
    var commitTitle = "Commit"
    var navigationTitle = "Note Card"
    
    let formalities = NoteCard.Formality.allCases.map({ $0.title })
    
    var selectedFormality: NoteCard.Formality {
        NoteCard.Formality(rawValue: Int64(formality)) ?? .unspecified
    }
    
    var selectedCollectionNoteCardCount: String {
        let count = selectedCollection.noteCards.count
        let card = count == 1 ? "CARD" : "CARDS"
        return "\(count) \(card)"
    }
    
    // MARK: Constructor
    init(collection: NoteCardCollection) {
        selectedCollection = collection
    }
}


extension NoteCardFormModel {
    
    func createNoteCardCUDRequest() -> NoteCardCUDRequest {
        NoteCardCUDRequest(
            collection: selectedCollection,
            native: native,
            translation: translation,
            formality: selectedFormality,
            isFavorite: isFavorite,
            note: note,
            relationships: selectedRelationships,
            tags: selectedTags
        )
    }
    
    func update(with noteCard: NoteCard) {
        selectedCollection = noteCard.collection!
        
        native = noteCard.native
        translation = noteCard.translation
        formality = Int(noteCard.formality.rawValue)
        isFavorite = noteCard.isFavorited
        note = noteCard.note
        
        selectedRelationships = noteCard.relationships
        selectedTags = noteCard.tags
    }
}
