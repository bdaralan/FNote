//
//  NoteCardCUDRequest.swift
//  FNote
//
//  Created by Dara Beng on 1/22/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation


class NoteCardCUDRequest: ObjectCUDRequest {
    
    var collection: NoteCardCollection
    var native: String
    var translation: String
    var formality: NoteCard.Formality
    var isFavorite: Bool
    var note: String
    var relationships: Set<NoteCard>
    var tags: Set<Tag>
    
    
    init(collection: NoteCardCollection, native: String, translation: String, formality: NoteCard.Formality, isFavorite: Bool, note: String, relationships: Set<NoteCard>, tags: Set<Tag>) {
        self.collection = collection
        self.native = native
        self.translation = translation
        self.formality = formality
        self.isFavorite = isFavorite
        self.note = note
        self.relationships = relationships
        self.tags = tags
    }
    
    
    func changeContext(_ context: ManagedObjectChildContext) {
        collection = collection.get(from: context)
        
        var relationshipsInContext = Set<NoteCard>()
        relationships.forEach({ relationshipsInContext.insert($0.get(from: context)) })
        relationships = relationshipsInContext
        
        var tagsInContext = Set<Tag>()
        tags.forEach({ tagsInContext.insert($0.get(from: context)) })
        tags = tagsInContext
    }
    
    func update(_ object: NoteCard) {
        object.collection = collection
        object.native = native
        object.translation = translation
        object.formality = formality
        object.isFavorite = isFavorite
        object.note = note
        object.setRelationships(relationships)
        object.setTags(tags)
    }
}
