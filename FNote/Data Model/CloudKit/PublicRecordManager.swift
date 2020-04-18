//
//  PublicRecordManager.swift
//  FNote
//
//  Created by Dara Beng on 3/6/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


class PublicRecordManager {
    
    typealias QueryCompletionBlock = (Result<[CKRecord], Error>) -> Void
    
    static let shared = PublicRecordManager()
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    private(set) var cache: NSCache<NSString, CKRecord> = {
        let cache = NSCache<NSString, CKRecord>()
        cache.countLimit = 200
        return cache
    }()
    
    func cachedRecord(forKey key: String) -> CKRecord? {
        cache.object(forKey: NSString(string: key))
    }
    
    func cacheRecords(_ records: [CKRecord], usingRecordKey key: String) {
        for record in records {
            guard let key = record[key] as? String else { return }
            cache.setObject(record, forKey: NSString(string: key))
        }
    }
    
    func cacheRecords(_ records: [CKRecord], usingRecordKey key: CodingKey) {
        for record in records {
            guard let key = record[key.stringValue] as? String else { return }
            cache.setObject(record, forKey: NSString(string: key))
        }
    }
    
    func performQuery(operation: CKQueryOperation, completion: @escaping QueryCompletionBlock) {
        var records = [CKRecord]()
        
        operation.recordFetchedBlock = { record in
            records.append(record)
        }
        
        operation.queryCompletionBlock = { cursor, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(records))
        }
        
        publicDatabase.add(operation)
    }
}


extension PublicRecordManager {
    
    func queryUsers(withIDs userIDs: [String], desiredKeys: [PublicUser.RecordKeys]? = nil,  completion: @escaping QueryCompletionBlock) {
        let userID = PublicUser.RecordKeys.userID.stringValue
        let predicate = NSPredicate(format: "\(userID) IN %@", userIDs)
        let query = CKQuery(recordType: PublicUser.recordType, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        if let keys = desiredKeys {
            operation.desiredKeys = keys.map({ $0.stringValue })
        }
        
        performQuery(operation: operation, completion: completion)
    }
    
    func queryRecentCollections(completion: @escaping QueryCompletionBlock) {
        let modificationDate = #keyPath(CKRecord.modificationDate)
        let predicate = NSPredicate(value: true)
        let sortByRecentModified = NSSortDescriptor(key: modificationDate, ascending: false)
        let query = CKQuery(recordType: PublicCollection.recordType, predicate: predicate)
        query.sortDescriptors = [sortByRecentModified]
        
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 50
        
        performQuery(operation: operation, completion: completion)
    }
    
    func queryCards(withCollectionID collectionID: String, completion: @escaping QueryCompletionBlock) {
        let cardCollectionID = PublicNoteCard.RecordKeys.collectionID.stringValue
        let cardTranslation = PublicNoteCard.RecordKeys.translation.stringValue
        let predicate = NSPredicate(format: "\(cardCollectionID) == %@", collectionID)
        let sortByTranslation = NSSortDescriptor(key: "\(cardTranslation)", ascending: true)
        
        let query = CKQuery(recordType: PublicNoteCard.recordType, predicate: predicate)
        query.sortDescriptors = [sortByTranslation]
        
        let operation = CKQueryOperation(query: query)
        performQuery(operation: operation, completion: completion)
    }
    
    func queryRecentCards(completion: @escaping QueryCompletionBlock) {
        let creationDate = #keyPath(CKRecord.creationDate)
        let predicate = NSPredicate(value: true)
        let sortByRecentCreate = NSSortDescriptor(key: creationDate, ascending: false)
        let query = CKQuery(recordType: PublicNoteCard.recordType, predicate: predicate)
        query.sortDescriptors = [sortByRecentCreate]
        
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 50
        
        performQuery(operation: operation, completion: completion)
    }
}


extension PublicRecordManager {
    
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
        
        publicDatabase.add(saveCollectionOP)
        publicDatabase.add(saveCardsOP)
    }
}


extension PublicRecordManager {
    
    /// Fetch user records and cache them.
    func fetchAndCacheUserRecord(userIDs: [String], completion: QueryCompletionBlock?) {
        queryUsers(withIDs: userIDs) { result in
            switch result {
            case .success(let records):
                self.cacheRecords(records, usingRecordKey: PublicUser.RecordKeys.userID)
                completion?(.success(records))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    func fetchPublicUserRecord(desiredKeys: [PublicUser.RecordKeys] = [], completion: @escaping (Result<CKRecord, Error>) -> Void) {
        // fetch current user ID
        CKContainer.default().fetchUserRecordID { record, error in
            guard let record = record else {
                completion(.failure(error!))
                return
            }
            
            // remove the underscore _ from the ID and use that ID to fetch PublicUser record
            let publicUserID = record.recordName.replacingOccurrences(of: "_", with: "")
            let recordID = CKRecord.ID(recordName: publicUserID)
            let operation = CKFetchRecordsOperation(recordIDs: [recordID])
            operation.qualityOfService = .userInitiated
            
            // set desired keys if provided
            if desiredKeys.isEmpty == false {
                let desiredKeys = [.userID] + desiredKeys
                operation.desiredKeys = desiredKeys.map(\.stringValue)
            }
            
            // set completion block
            operation.fetchRecordsCompletionBlock = { recordMap, error in
                guard let record = recordMap?[recordID] else {
                    completion(.failure(error!))
                    return
                }
                
                completion(.success(record))
            }
            
            // begin the operation
            self.publicDatabase.add(operation)
        }
    }
    
    func save(record: CKRecord, completion: ((Result<CKRecord, Error>) -> Void)?) {
        publicDatabase.save(record) { record, error in
            if let record = record {
                completion?(.success(record))
            } else {
                completion?(.failure(error!))
            }
        }
    }
}


extension PublicRecordManager {
    
    func setupTestCKSubscriptions() {
//        let collectionRecordType = PublicCollection.recordType
//        let newCollectionPredicate = NSPredicate(value: true)
//        let newCollectionSubID = "newCollectionSubID"
//        let newCollectionFireOptions: CKQuerySubscription.Options = [.firesOnRecordCreation, .firesOnRecordUpdate]
//        let newCollectionSub = CKQuerySubscription(recordType: collectionRecordType, predicate: newCollectionPredicate, subscriptionID: newCollectionSubID, options: newCollectionFireOptions)
//
//        let newCollectionSubOP = CKModifySubscriptionsOperation(subscriptionsToSave: [newCollectionSub], subscriptionIDsToDelete: [])
//        publicDatabase.add(newCollectionSubOP)
    }
}
