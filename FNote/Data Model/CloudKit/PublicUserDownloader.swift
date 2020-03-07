//
//  PublicUserDownloader.swift
//  FNote
//
//  Created by Dara Beng on 3/6/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import CloudKit


class PublicUserDownloader {
    
    static var cache = [String: CKRecord]()
    
    let database = CKContainer.default().publicCloudDatabase
    
    func download(userIDs: [String], completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        let userID = PublicUser.RecordKeys.userID.stringValue
        let predicate = NSPredicate(format: "\(userID) IN %@", userIDs)
        let query = CKQuery(recordType: PublicUser.recordType, predicate: predicate)
        
        let queryOP = CKQueryOperation(query: query)
        
        var records = [CKRecord]()
        queryOP.recordFetchedBlock = { record in
            records.append(record)
        }
        
        queryOP.queryCompletionBlock = { cursor, error in
            if let error = error {
                print("⚠️ failed to fetch PublicUser with error: \(error) ⚠️")
                completion(.failure(error))
                return
            }
            
            completion(.success(records))
        }
        
        database.add(queryOP)
    }
}
