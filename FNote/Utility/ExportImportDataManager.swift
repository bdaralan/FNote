//
//  ExportImportDataManager.swift
//  FNote
//
//  Created by Dara Beng on 1/27/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation
import CoreData


struct ExportImportDataManager {
    
    var context: NSManagedObjectContext
    
    /// Export all data as JSON to document directory.
    @discardableResult
    func exportData(to url: URL) -> Data? {
        let collectionRequest = NoteCardCollection.requestAllCollections()
        let noteCardRequest = NoteCard.requestAllNoteCards()
        let tagRequest = Tag.requestAllTags()
        
        do {
            // fetch all objects
            let collections = try context.fetch(collectionRequest)
            let noteCards = try context.fetch(noteCardRequest)
            let tags = try context.fetch(tagRequest)
            
            // encode objects
            let collectionData = collections.map({ NoteCardCollectionData(collection: $0) })
            let tagData = tags.map({ TagData(tag: $0) })
            let noteCardData = noteCards.map({ NoteCardData(noteCard: $0) })
            
            // create data
            let exportData = ExportData(
                collections: collectionData,
                noteCards: noteCardData,
                tags: tagData
            )
            
            // decode data
            let data = try JSONEncoder().encode(exportData)
            
            // write data to URL
            try data.write(to: url, options: .atomic)
            
            return data

        } catch {
            print("⚠️ failed to export data with error: \(error) ⚠️")
            return nil
        }
    }
    
    /// Create objects from the json at URL.
    ///
    /// - Returns: The child managed object of the `context`.
    /// - Note: To commit the imported objects, save the returned context and its parent context.
    func importData(from url: URL, deleteCurrentData: Bool = false) -> NSManagedObjectContext? {
        let importContext = context.newChildContext(type: .mainQueueConcurrencyType, mergesChangesFromParent: false)
        do {
            let data = try Data(contentsOf: url)
            let exportData = try JSONDecoder().decode(ExportData.self, from: data)
            
            // String is the object ID
            var collectionMap = [String: NoteCardCollection]()
            var tagMap = [String: Tag]()
            var noteCardMap = [String: NoteCard]()
            
            // create collections
            for data in exportData.collections {
                let collection = NoteCardCollection(context: importContext)
                collectionMap[data.uuid] = collection
                data.setPrimitiveValues(to: collection)
            }
            
            // create tags
            for data in exportData.tags {
                let tag = Tag(context: importContext)
                tagMap[data.uuid] = tag
                data.setPrimitiveValues(to: tag)
            }
            
            // create note cards
            for data in exportData.noteCards {
                let noteCard = NoteCard(context: importContext)
                noteCardMap[data.uuid] = noteCard
                data.setPrimitiveValues(to: noteCard)
            }
            
            // set collection, relationships, and tags to note cards
            for data in exportData.noteCards {
                let noteCard = noteCardMap[data.uuid]!
                let collection = collectionMap[data.collectionID]!
                let relationships = data.relationshipIDs.compactMap({ noteCardMap[$0] })
                let tags = data.tagIDs.compactMap({ tagMap[$0] })
                noteCard.collection = collection
                noteCard.setRelationships(Set(relationships))
                noteCard.setTags(Set(tags))
            }
            
            if deleteCurrentData {
                eraseCurrentData()
            
            } else {
                // step 1 - fetch all tags
                let existingTagRequest = Tag.requestAllTags()
                let existingTags = try context.fetch(existingTagRequest)
        
                // step 2 - map them into key value pairs
                
                // key is the existing tag's name lowercased
                // value is the existing tag
                var existingTagMap = [String: Tag]()
                
                for existingTag in existingTags {
                    existingTagMap[existingTag.name.lowercased()] = existingTag.get(from: importContext)
                }
                
                var importingTagsToDelete = Set<Tag>()
                
                // step 3 - find matching tag and add the existing into note cards
                for importingTag in tagMap.values {
                    let lowercasedName = importingTag.name.lowercased()
                    if let existingTag = existingTagMap[lowercasedName] {
                        importingTagsToDelete.insert(importingTag)
                        for noteCard in importingTag.noteCards {
                            if noteCard.tags.contains(importingTag) {
                                noteCard.addTags([existingTag])
                            }
                        }
                    }
                }
                
                // step 4 - delete the matching importing tags
                for importingTag in importingTagsToDelete {
                    importContext.delete(importingTag)
                }
            }
            
            return importContext
        
        } catch {
            print("⚠️ failed to import data with error: \(error) ⚠️")
            return nil
        }
    }
    
    private func eraseCurrentData() {
        let collectionRequest = NoteCardCollection.requestAllCollections()
        let tagRequest = Tag.requestAllTags()
        
        let collections = try? context.fetch(collectionRequest)
        let tags = try? context.fetch(tagRequest)
    
        collections?.forEach({ context.delete($0) })
        tags?.forEach({ context.delete($0) })
    }
}


extension ExportImportDataManager {
    
    @discardableResult
    static func copyFileToDocumentFolder(fileURL: URL) -> Bool {
        let fileManager = FileManager.default
        let documentFolder = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentFolder.appendingPathComponent(fileURL.lastPathComponent)
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: fileURL, to: destinationURL)
            return true
        
        } catch {
            print("⚠️ failed to copy file to document folder with error: \(error)\n\(fileURL) ⚠️")
            return false
        }
    }
}


// MARK: - Export Data

fileprivate struct ExportData: Codable {
    var collections: [NoteCardCollectionData]
    var noteCards: [NoteCardData]
    var tags: [TagData]
}


// MARK: - Note Card Data

fileprivate struct NoteCardData: Codable {
    var uuid: String
    var native: String
    var translation: String
    var formality: Int
    var isFavorite: Bool
    var note: String
    var collectionID: String
    var relationshipIDs: [String]
    var tagIDs: [String]
}


extension NoteCardData {
    
    init(noteCard: NoteCard) {
        self.init(
            uuid: noteCard.uuid,
            native: noteCard.native,
            translation: noteCard.translation,
            formality: Int(noteCard.formality.rawValue),
            isFavorite: noteCard.isFavorite,
            note: noteCard.note,
            collectionID: noteCard.collection!.uuid,
            relationshipIDs: noteCard.relationships.map({ $0.uuid }),
            tagIDs: noteCard.tags.map({ $0.uuid })
        )
    }
    
    func setPrimitiveValues(to noteCard: NoteCard) {
        noteCard.native = native
        noteCard.translation = translation
        noteCard.formality = NoteCard.Formality(rawValue: Int64(formality)) ?? .unspecified
        noteCard.isFavorite = isFavorite
        noteCard.note = note
    }
}


// MARK: - Note Card Collection Data

fileprivate struct NoteCardCollectionData: Codable {
    var uuid: String
    var name: String
    var noteCardIDs: [String]
}


extension NoteCardCollectionData {
    
    init(collection: NoteCardCollection) {
        self.init(
            uuid: collection.uuid,
            name: collection.name,
            noteCardIDs: collection.noteCards.map({ $0.uuid })
        )
    }
    
    func setPrimitiveValues(to collection: NoteCardCollection) {
        collection.name = name
    }
}


// MARK: - Tag Data

fileprivate struct TagData: Codable {
    var uuid: String
    var name: String
    var noteCardIDs: [String]
}


extension TagData {
    
    init(tag: Tag) {
        self.init(
            uuid: tag.uuid,
            name: tag.name,
            noteCardIDs: tag.noteCards.map({ $0.uuid })
        )
    }
    
    func setPrimitiveValues(to tag: Tag) {
        tag.name = name
    }
}
