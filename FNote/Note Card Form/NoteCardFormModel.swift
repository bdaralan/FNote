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
    
    // MARK: Required Property
    var context: NSManagedObjectContext
    
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
    @Published var selectedRelationships: [NoteCard] = []
    @Published var selectedTags: [Tag] = []
    
    // MARK: Action
    var onTagSelected: (() -> Void)?
    var onCollectionSelected: (() -> Void)?
    
    var onCancel: (() -> Void)?
    var onCommit: (() -> Void)?
    
    // MARK: UI Property
    var nativePlaceholder = "안영"
    var translationPlaceholder = "Hi"
    var commitTitle = "Commit"
    var navigationTitle = "Note Card"
    
    let formalities = NoteCard.Formality.allCases.map({ $0.title })
    
    var selectedFormality: NoteCard.Formality {
        NoteCard.Formality(rawValue: Int64(formality)) ?? .unspecified
    }
    
    var formalitySegmentColor: UIColor? {
        let formality = selectedFormality
        return formality == .unspecified ? nil : formality.uiColor
    }
    
    var selectedCollectionNoteCardCount: String {
        let count = selectedCollection.noteCards.count
        let card = count == 1 ? "CARD" : "CARDS"
        return "\(count) \(card)"
    }
    
    // MARK: Constructor
    init(context: NSManagedObjectContext, collection: NoteCardCollection) {
        self.context = context
        selectedCollection = collection.get(from: context)
    }
}


extension NoteCardFormModel {
    
    func update(with noteCard: NoteCard) {
        native = noteCard.native
        translation = noteCard.translation
        formality = Int(noteCard.formality.rawValue)
        isFavorite = noteCard.isFavorited
        note = noteCard.note
        
        selectedCollection = noteCard.collection!
        selectedRelationships = Array(noteCard.relationships)
        selectedTags = Array(noteCard.tags)
    }
    
    func apply(to noteCard: NoteCard) {
        let noteCard = noteCard.get(from: context)
        
        noteCard.native = native
        noteCard.translation = translation
        noteCard.formality = selectedFormality
        noteCard.isFavorited = isFavorite
        noteCard.note = note
        
        noteCard.collection = selectedCollection
        
        selectedRelationships.forEach { relationship in
            let relationship = relationship.get(from: context)
            noteCard.relationships.insert(relationship)
        }
        
        selectedTags.forEach { tag in
            let tag = tag.get(from: context)
            noteCard.tags.insert(tag)
        }
    }
}
