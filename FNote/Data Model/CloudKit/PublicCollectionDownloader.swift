//
//  PublicCollectionDownloader.swift
//  FNote
//
//  Created by Dara Beng on 3/6/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


class PublicCollectionDownloader {
    
    let database = CKContainer.default().publicCloudDatabase
    
    
    func downloadCollections(completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        let modificationDate = #keyPath(CKRecord.modificationDate)
        let predicate = NSPredicate(value: true)
        let sortByRecentModified = NSSortDescriptor(key: modificationDate, ascending: false)
        let query = CKQuery(recordType: PublicCollection.recordType, predicate: predicate)
        query.sortDescriptors = [sortByRecentModified]
        
        let queryOP = CKQueryOperation(query: query)
        queryOP.resultsLimit = 50
        
        var fetchedRecords = [CKRecord]()
        
        queryOP.recordFetchedBlock = { record in
            fetchedRecords.append(record)
        }
        
        queryOP.queryCompletionBlock = { cursor, error in
            if let error = error {
                print("⚠️ failed to query publish collection with error: \(error) ⚠️")
                completion(.failure(error))
                return
            }
            
            completion(.success(fetchedRecords))
        }
        
        database.add(queryOP)
    }
    
    func downloadCards(collectionID: String, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        let cardsCollectionID = PublicNoteCard.RecordKeys.collectionID.stringValue
        let predicate = NSPredicate(format: "\(cardsCollectionID) == %@", collectionID)
        let cardQuery = CKQuery(recordType: PublicNoteCard.recordType, predicate: predicate)
        let cardQueryOP = CKQueryOperation(query: cardQuery)

        var cardRecords = [CKRecord]()

        cardQueryOP.recordFetchedBlock = { record in
            cardRecords.append(record)
        }

        cardQueryOP.queryCompletionBlock = { cursor, error in
            if let error = error {
                // handle error
                print(error)
                completion(.failure(error))
            } else {
                completion(.success(cardRecords))
            }
        }

        database.add(cardQueryOP)
    }
}
