//
//  PublicDatabaseManager.swift
//  FNote
//
//  Created by Dara Beng on 2/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


class PublicCollectionUploader {
    
    let database = CKContainer.default().publicCloudDatabase
    
    
    func upload(collection: PublicCollection, with cards: [PublicNoteCard], completion: @escaping (Result<(CKRecord, [CKRecord]), Error>) -> Void) {
        // create CKRecord to upload
        let collectionRecord = collection.createCKRecord()
        let cardRecords = cards.map({ $0.createCKRecord() })
        
        // create save operations
        let saveCollectionOP = CKModifyRecordsOperation(recordsToSave: [collectionRecord])
        saveCollectionOP.savePolicy = .allKeys
        
        saveCollectionOP.modifyRecordsCompletionBlock = { savedRecords, _, error in
            if let error = error {
                print("📝 handle CK error: \(error) 📝")
                completion(.failure(error))
            }
        }
        
        let saveCardsOP = CKModifyRecordsOperation(recordsToSave: cardRecords)
        saveCardsOP.savePolicy = .allKeys
        saveCardsOP.addDependency(saveCollectionOP)
        
        saveCardsOP.modifyRecordsCompletionBlock = { savedRecords, _, error in
            if let error = error {
                print("📝 handle CK error: \(error) 📝")
                completion(.failure(error))
                return
            }
            
            if let savedRecords = savedRecords {
                print("published collection \(collection.name) with \(savedRecords.count) cards")
                completion(.success((collectionRecord, savedRecords)))
            }
        }
        
        database.add(saveCollectionOP)
        database.add(saveCardsOP)
    }
}
