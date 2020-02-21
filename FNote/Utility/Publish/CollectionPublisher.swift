//
//  CollectionPublisher.swift
//  FNote
//
//  Created by Dara Beng on 2/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


class CollectionPublisher {
    
    let collection: PublishedCollection
    let cards: [NoteCard]
    
    var includeNote = true
    
    init(collection: PublishedCollection, cards: [NoteCard]) {
        self.collection = collection
        self.cards = cards
    }
}


// MARK: - Publish Method

extension CollectionPublisher {
    
    func publish(to database: CKDatabase, completion: (([CKRecord]?) -> Void)?) {
        // hold card publishedID
        var publishIDMap = [String: String]() // [uuid: publishedID]
        
        // create card to publish
        var publishCards = cards.map { card -> PublishedNoteCard in
            let publishCard = PublishedNoteCard(
                publishedCollectionID: collection.publishedID,
                publishedID: UUID().uuidString,
                native: card.native,
                translation: card.translation,
                favorited: card.isFavorite,
                formality: Int(card.formality.rawValue),
                note: includeNote ? card.note : "",
                tags: card.tags.map({ $0.name }),
                relationships: card.relationships.map({ $0.uuid }) // need to be updated to publish ID
            )
            
            publishIDMap[card.uuid] = publishCard.publishedID
            
            return publishCard
        }
        
        // create collection record
        let collectionRecord = collection.ckRecord()
        
        // create card records
        let cardRecords = publishCards.enumerated().map { index, publishCard -> CKRecord in
            // update relationship IDs to publish IDs before create record
            // cross collection relationship is not supported so use compactMap
            let relationPublishIDs = publishCard.relationships.compactMap({ publishIDMap[$0] })
            publishCards[index].relationships = relationPublishIDs
            return publishCards[index].ckRecord()
        }
        
        let saveCollectionOP = CKModifyRecordsOperation(recordsToSave: [collectionRecord])
        saveCollectionOP.savePolicy = .allKeys
        
        let saveCardsOP = CKModifyRecordsOperation(recordsToSave: cardRecords)
        saveCardsOP.savePolicy = .allKeys
        saveCardsOP.addDependency(saveCollectionOP)
        
        saveCardsOP.modifyRecordsCompletionBlock = { savedRecord, deletedRIDs, error in
            if let error = error {
                print("📝 handle ck error: \(error) 📝")
            }
        }
        
        saveCardsOP.modifyRecordsCompletionBlock = { savedRecords, deleteRIDs, error in
            if let error = error {
                print("📝 handle ck error: \(error) 📝")
            }
            
            guard let savedRecords = savedRecords else { return }
            print("published collection \(self.collection.name) with \(savedRecords.count) cards")
            completion?(savedRecords)
        }
        
        database.add(saveCollectionOP)
        database.add(saveCardsOP)
    }
}


// MARK: - Download Method

extension CollectionPublisher {
    
    static func download(_ collection: PublishedCollection, from database: CKDatabase, completion: (([PublishedNoteCard]?) -> Void)?) {
        let publishedID = collection.publishedID
        
        let predicate = NSPredicate(format: "publishedCollectionID == %@", publishedID)
        let query = CKQuery(recordType: PublishedCollection.ckRecordType, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        var publishedCards = [PublishedNoteCard]()
        
        queryOperation.recordFetchedBlock = { record in
            let publishedCard = PublishedNoteCard(record: record)
            publishedCards.append(publishedCard)
        }
        
        queryOperation.queryCompletionBlock = { cursor, error in
            if let error = error {
                // handle error
                print(error)
            } else {
                completion?(publishedCards)
            }
        }
        
        database.add(queryOperation)
    }
}
