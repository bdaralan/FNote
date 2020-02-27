//
//  DatabasePublisher.swift
//  FNote
//
//  Created by Dara Beng on 2/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


class DatabasePublisher {
    
    let database: CKDatabase
    
    init(database: CKDatabase) {
        self.database = database
    }
}


// MARK: - Publish Method

extension DatabasePublisher {
    
    enum DatabaseError: Error {
        case internalFailure
        case connection
    }

    enum DatabaseResult {
        case published(collection: CKRecord, cards: [CKRecord])
        case downloaded(cards: [CKRecord])
    }
    
    func publish(
        collection: PublishCollection,
        cards: [PublishNoteCard],
        completion: @escaping (Result<DatabaseResult, DatabaseError>) -> Void
    ) {
        // create CKRecord to upload
        let collectionRecord = collection.createCKRecord()
        let cardRecords = cards.map({ $0.createCKRecord() })
        
        // create save operations
        let saveCollectionOP = CKModifyRecordsOperation(recordsToSave: [collectionRecord])
        saveCollectionOP.savePolicy = .allKeys
        
        saveCollectionOP.modifyRecordsCompletionBlock = { savedRecords, _, error in
            if let error = error {
                print("📝 handle CK error: \(error) 📝")
                completion(.failure(.internalFailure))
            }
        }
        
        let saveCardsOP = CKModifyRecordsOperation(recordsToSave: cardRecords)
        saveCardsOP.savePolicy = .allKeys
        saveCardsOP.addDependency(saveCollectionOP)
        
        saveCardsOP.modifyRecordsCompletionBlock = { savedRecords, _, error in
            if let error = error {
                print("📝 handle CK error: \(error) 📝")
                completion(.failure(.internalFailure))
            }
            
            guard let savedRecords = savedRecords else { return }
            print("published collection \(collection.name) with \(savedRecords.count) cards")
            completion(.success(.published(collection: collectionRecord, cards: cardRecords)))
        }
        
        database.add(saveCollectionOP)
        database.add(saveCardsOP)
    }
}


// MARK: - Download Method

extension DatabasePublisher {
    
    func downloadCards(
        for collection: PublishCollection,
        completion: @escaping (Result<DatabaseResult, DatabaseError>) -> Void
    ) {
        let collectionID = PublishNoteCard.RecordKeys.publishedCollectionID.stringValue
        let predicate = NSPredicate(format: "\(collectionID) == %@", collection.publishedID)
        let cardQuery = CKQuery(recordType: PublishNoteCard.recordType, predicate: predicate)
        let cardQueryOP = CKQueryOperation(query: cardQuery)

        var cardRecords = [CKRecord]()

        cardQueryOP.recordFetchedBlock = { record in
            cardRecords.append(record)
        }

        cardQueryOP.queryCompletionBlock = { cursor, error in
            if let error = error {
                // handle error
                print(error)
                completion(.failure(.internalFailure))
            } else {
                completion(.success(.downloaded(cards: cardRecords)))
            }
        }

        database.add(cardQueryOP)
    }
}
