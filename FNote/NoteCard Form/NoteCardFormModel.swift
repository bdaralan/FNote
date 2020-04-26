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
    
    @Published var selectedCollection: NoteCardCollection?
    @Published var selectedRelationships: Set<NoteCard> = []
    @Published var selectedTags: Set<Tag> = []
    
    @Published var relationshipSelectedCollection: NoteCardCollection?
    
    var selectedNoteCard: NoteCard?
    
    // MARK: Action
    var onCollectionSelected: ((NoteCardCollection) -> Void)?
    var onRelationshipSelected: ((NoteCard) -> Void)?
    var onTagSelected: ((Tag) -> Void)?
    var onCreateTag: ((String) -> Tag?)?
    
    var onRelationshipCollectionSelected: ((NoteCardCollection) -> Void)?
    
    var onCancel: (() -> Void)?
    var onCommit: (() -> Void)?
    
    
    // MARK: UI Property
    
    /// A value indicate that the view should show keyboard on appeared.
    var presentWithKeyboard = false
    
    /// Used to control NavigationLink
    @Published var isSelectingCollection = false
    
    /// Used to control NavigationLink
    @Published var isSelectingTag = false
    
    /// Used to control NavigationLink
    @Published var isSelectingRelationship = false
    
    var canCommit: Bool {
        return !translation.trimmed().isEmpty
            && !native.trimmed().isEmpty
    }
    
    var presentingTitle: String {
        isSelectingTag || isSelectingRelationship || isSelectingCollection ? "Card" : navigationTitle
    }
    
    var nativePlaceholder = "안녕"
    var translationPlaceholder = "Hi"
    var commitTitle = "Commit"
    var navigationTitle = "Note Card"
    
    let formalities = NoteCard.Formality.allCases.map({ $0.title })
    
    var selectedFormality: NoteCard.Formality {
        NoteCard.Formality(rawValue: Int64(formality)) ?? .unspecified
    }
    
    var selectedCollectionNoteCardCount: String {
        guard let collection = selectedCollection else { return "" }
        let count = collection.noteCards.count
        let card = count == 1 ? "CARD" : "CARDS"
        return "\(count) \(card)"
    }
    
    // MARK: Constructor
    
    /// Construct model with collection and note card.
    /// - Parameters:
    ///   - collection: The selected collection.
    ///   - noteCard: The note card currently working on.
    init(collection: NoteCardCollection? = nil, noteCard: NoteCard? = nil) {
        self.selectedCollection = collection
        self.selectedNoteCard = noteCard
    }
}


extension NoteCardFormModel {
    
    var uiCollectionName: String {
        selectedCollection?.name ?? "none"
    }
    
    var uiCollectionCardsCount: String {
        guard let collection = selectedCollection else { return "" }
        let count = collection.noteCards.count
        let card = count == 1 ? "CARD" : "CARDS"
        return "\(count) \(card)"
    }
    
    var uiTagsCount: String {
        "\(selectedTags.count)"
    }
    
    var uiRelationshipsCount: String {
        "\(selectedRelationships.count)"
    }
    
    var uiCompactNote: String {
        note.trimmed()
    }
}


extension NoteCardFormModel {
    
    func update(with noteCard: NoteCard) {
        selectedCollection = noteCard.collection!
        
        native = noteCard.native
        translation = noteCard.translation
        formality = Int(noteCard.formality.rawValue)
        isFavorite = noteCard.isFavorite
        note = noteCard.note
        
        selectedRelationships = noteCard.relationships
        selectedTags = noteCard.tags
    }
}
