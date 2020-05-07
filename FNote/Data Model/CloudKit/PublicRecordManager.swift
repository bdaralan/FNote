//
//  PublicRecordManager.swift
//  FNote
//
//  Created by Dara Beng on 3/6/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


class PublicRecordManager {
    
    // MARK: Typealias
    
    typealias QueryCompletionBlock = (Result<[CKRecord], Error>) -> Void
    
    
    // MARK: Singleton
    
    static let shared = PublicRecordManager()
    
    
    // MARK: Notification
    
    static let nPublicUserDidUpdate = Notification.Name("PublicRecordManager.nPublicUserDidUpdate")
    
    
    // MARK: Property
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    private(set) var recordCache: NSCache<NSString, CKRecord> = {
        let cache = NSCache<NSString, CKRecord>()
        cache.countLimit = 200
        return cache
    }()
    
    func cachedRecord(forKey key: String) -> CKRecord? {
        recordCache.object(forKey: NSString(string: key))
    }
    
    func cacheRecords(_ records: [CKRecord], usingRecordField field: String) {
        for record in records {
            guard let key = record[field] as? String else { return }
            recordCache.setObject(record, forKey: NSString(string: key))
        }
    }
    
    func cacheRecords(_ records: [CKRecord], usingRecordField field: RecordField) {
        for record in records {
            guard let key = record[field.stringValue] as? String else { return }
            recordCache.setObject(record, forKey: NSString(string: key))
        }
    }
    
    func cacheRecords(_ records: Set<CKRecord>, usingRecordField field: RecordField) {
        for record in records {
            guard let key = record[field.stringValue] as? String else { return }
            recordCache.setObject(record, forKey: NSString(string: key))
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


// MARK: - Query Record

extension PublicRecordManager {
    
    func queryUsers(withIDs userIDs: [String], desiredFields: [PublicUser.RecordFields]? = nil,  completion: @escaping QueryCompletionBlock) {
        let userIDField = PublicUser.RecordFields.userID.stringValue
        let predicate = NSPredicate(format: "\(userIDField) IN %@", userIDs)
        let query = CKQuery(recordType: PublicUser.recordType, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        if let fields = desiredFields {
            operation.desiredKeys = fields.map({ $0.stringValue })
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
    
    func queryCards(withCollectionID collectionID: String, desiredFields: [PublicCard.RecordFields]? = nil, completion: @escaping QueryCompletionBlock) {
        let collectionIDField = PublicCard.RecordFields.collectionID.stringValue
        let translationField = PublicCard.RecordFields.translation.stringValue
        
        let predicate = NSPredicate(format: "\(collectionIDField) == %@", collectionID)
        let sortByTranslation = NSSortDescriptor(key: "\(translationField)", ascending: true)
        
        let query = CKQuery(recordType: PublicCard.recordType, predicate: predicate)
        query.sortDescriptors = [sortByTranslation]
        
        let operation = CKQueryOperation(query: query)
        
        if let desiredFields = desiredFields {
            operation.desiredKeys = desiredFields.map(\.stringValue)
        }
        
        performQuery(operation: operation, completion: completion)
    }
    
    func queryCards(withIDs cardIDs: [String], completion: @escaping QueryCompletionBlock) {
        let cardIDField = PublicCard.RecordFields.cardID.stringValue
        let nativeField = PublicCard.RecordFields.native.stringValue
        let translationField = PublicCard.RecordFields.translation.stringValue
        
        let predicate = NSPredicate(format: "\(cardIDField) IN %@", cardIDs)
        let sortByNative = NSSortDescriptor(key: nativeField, ascending: true)
        let sortByTranslation = NSSortDescriptor(key: translationField, ascending: true)
        
        let query = CKQuery(recordType: PublicCard.recordType, predicate: predicate)
        query.sortDescriptors = [sortByNative, sortByTranslation]
        
        let operation = CKQueryOperation(query: query)
        performQuery(operation: operation, completion: completion)
    }
    
    func queryRecentCards(completion: @escaping QueryCompletionBlock) {
        let creationDate = #keyPath(CKRecord.creationDate)
        let predicate = NSPredicate(value: true)
        let sortByRecentCreate = NSSortDescriptor(key: creationDate, ascending: false)
        let query = CKQuery(recordType: PublicCard.recordType, predicate: predicate)
        query.sortDescriptors = [sortByRecentCreate]
        
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 50
        
        performQuery(operation: operation, completion: completion)
    }
}


// MARK: - Upload Record

extension PublicRecordManager {
    
    func upload(collection: PublicCollection, with cards: [PublicCard], completion: @escaping (Result<(CKRecord, [CKRecord]), Error>) -> Void) {
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


// MARK: - Fetch User Record

extension PublicRecordManager {
    
    /// Fetch user records and cache them.
    func fetchAndCacheUserRecord(userIDs: [String], completion: QueryCompletionBlock?) {
        queryUsers(withIDs: userIDs) { result in
            switch result {
            case .success(let records):
                self.cacheRecords(records, usingRecordField: PublicUser.RecordFields.userID)
                completion?(.success(records))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    func fetchPublicUserRecord(desiredFields: [PublicUser.RecordFields]? = nil, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        // fetch current user ID
        CKContainer.default().fetchUserRecordID { recordID, error in
            guard let recordID = recordID else {
                completion(.failure(error!))
                return
            }
            
            // remove the underscore _ from the ID and use that ID to fetch PublicUser record
            let publicUserID = recordID.recordName.replacingOccurrences(of: "_", with: "")
            let publicRecordID = CKRecord.ID(recordName: publicUserID)
            let operation = CKFetchRecordsOperation(recordIDs: [publicRecordID])
            operation.qualityOfService = .userInitiated
            
            // set desired keys if provided
            if let fields = desiredFields {
                operation.desiredKeys = fields.map(\.stringValue)
            }
            
            // set completion block
            operation.fetchRecordsCompletionBlock = { recordMap, error in
                guard let record = recordMap?[publicRecordID] else {
                    completion(.failure(error!))
                    return
                }
                
                completion(.success(record))
            }
            
            // begin the operation
            self.publicDatabase.add(operation)
        }
    }
    
    /// Save user record and update public collections author name.
    /// 
    /// - Parameters:
    ///   - record: The user record to save.
    ///   - completion: The completion with result of a user record or an error.
    func saveUserRecord(_ record: CKRecord, completion: @escaping (Result<CKRecord, CKError>) -> Void) {
        let user = PublicUser(record: record)
        var collectionRecords = [CKRecord]()
        
        let authorIDField = PublicCollection.RecordFields.authorID.stringValue
        let predicate = NSPredicate(format: "\(authorIDField) == %@", user.userID)
        let query = CKQuery(recordType: PublicCollection.recordType, predicate: predicate)
        let queryOP = CKQueryOperation(query: query)
        queryOP.qualityOfService = .userInitiated
        queryOP.desiredKeys = []
        
        queryOP.recordFetchedBlock = { record in
            var modifier = RecordModifier<PublicCollection.RecordFields>(record: record)
            modifier[.authorName] = user.username
            collectionRecords.append(record)
        }
        
        queryOP.queryCompletionBlock = { cursor, error in
            guard error == nil else {
                let error = error as! CKError
                completion(.failure(error))
                return
            }
            
            let recordsToSave = [record] + collectionRecords
            let saveOP = CKModifyRecordsOperation(recordsToSave: recordsToSave)
            saveOP.qualityOfService = .userInitiated
            
            saveOP.modifyRecordsCompletionBlock = { savedRecords, _, error in
                guard savedRecords?.isEmpty == false else {
                    let error = error as! CKError
                    completion(.failure(error))
                    return
                }
                completion(.success(record))
            }
            
            self.publicDatabase.add(saveOP)
        }
        
        publicDatabase.add(queryOP)
    }
    
    /// Attempt to create a public user record if first time user.
    ///
    /// - Parameter completion: Return a newly created or an existing record, or an error if failed.
    func createInitialPublicUserRecord(username: String = "", userBio: String = "", completion: @escaping (Result<CKRecord, CKError>) -> Void) {
        CKContainer.default().fetchUserRecordID { recordID, error in
            guard let recordID = recordID else {
                let error = error as! CKError
                completion(.failure(error))
                return
            }
            
            // remove the underscore _ from the ID and use that ID to fetch PublicUser record
            let publicUserID = recordID.recordName.replacingOccurrences(of: "_", with: "")
            let publicRecordID = CKRecord.ID(recordName: publicUserID)
            
            self.publicDatabase.fetch(withRecordID: publicRecordID) { record, error in
                if let record = record {
                    completion(.success(record))
                    return
                }
                
                // create initial public user record here
                if let ckError = error as? CKError, ckError.code == .unknownItem {
                    let newUser = PublicUser(userID: publicUserID, username: username, about: userBio)
                    let newRecord = newUser.createCKRecord()
                    self.publicDatabase.save(newRecord) { record, error in
                        if let record = record {
                            completion(.success(record))
                        } else {
                            let error = error as! CKError
                            completion(.failure(error))
                        }
                    }
                    return
                }
                
                let error = error as! CKError
                completion(.failure(error))
            }
        }
    }
}


// MARK: - Record Token

extension PublicRecordManager {
    
    func deleteRecordToken(tokenID: String, completion: @escaping (Result<CKRecord.ID, CKError>) -> Void) {
        let recordID = CKRecord.ID(recordName: tokenID)
        publicDatabase.delete(withRecordID: recordID) { recordID, error in
            if let recordID = recordID {
                completion(.success(recordID))
            }
            completion(.failure(error as! CKError))
        }
    }
    
    func sendLike(
        senderID: String,
        receiverID: String,
        token: PublicRecordToken.TokenType,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        // check if it exist
        
        let tokenID = PublicRecordToken.createTokenID(senderID: senderID, receiverID: receiverID, token: token)
        let tokenRID = CKRecord.ID(recordName: tokenID)
        
        publicDatabase.fetch(withRecordID: tokenRID) { record, error in
            if let record = record { // delete action
                self.publicDatabase.delete(withRecordID: tokenRID) { recordID, error in
                    print("📝 delete token with ID:    \(record.recordID.recordName) 📝")
                    completion(.success(false))
                }
                return
            }
            
            if let error = error as? CKError, error.code == .unknownItem { // create action
                let likeToken = PublicRecordToken(senderID: senderID, receiverID: receiverID, token: token)
                let tokenRecord = likeToken.createCKRecord()
                self.publicDatabase.save(tokenRecord) { record, error in
                    // handle completion
                    if let record = record {
                        print("📝 save like token with ID: \(record.recordID.recordName) 📝")
                        completion(.success(true))
                    } else {
                        print("save failed with error: \(error!)")
                        completion(.failure(error as! CKError))
                    }
                }
                return
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
    
    func setupPublicUserUpdateSubscriptions(userID: String, completion: ((Result<CKSubscription, CKError>) -> Void)?) {
        let subscriptionID = "CKSUBID.PublicUser.CU"
        let options: CKQuerySubscription.Options = [.firesOnRecordCreation, .firesOnRecordUpdate]
        let userIDField = PublicUser.RecordFields.userID.stringValue
        let predicate = NSPredicate(format: "\(userIDField) == %@", userID)
        
        let subscription = CKQuerySubscription(
            recordType: PublicUser.recordType,
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: options
        )
        
        let notification = CKQuerySubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        
        subscription.notificationInfo = notification
        
        publicDatabase.save(subscription) { subscription, error in
            if let subscription = subscription {
                completion?(.success(subscription))
            } else {
                completion?(.failure(error as! CKError))
            }
        }
    }
}
