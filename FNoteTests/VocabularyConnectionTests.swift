//
//  VocabularyConnectionTests.swift
//  FNoteTests
//
//  Created by Veronica Sumariyanto on 4/15/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import XCTest
import CoreData
@testable import FNote


#warning("TODO: fix cannot run all tests at once")
class VocabularyConnectionTests: XCTestCase {
    
    var coreData: CoreDataStack {
        return CoreDataStack.current
    }
    
    var mainContext: NSManagedObjectContext {
        return CoreDataStack.current.mainContext
    }
    
    
    override func setUp() {
        let testAccountToken = UUID().uuidString // a random-unique string
        CoreDataStack.setPersistentStore(userAccountToken: testAccountToken)
    }
    
    override func tearDown() {
        do {
            try FileManager.default.removeItem(at: coreData.persistentStoreUrl)
        } catch {
            fatalError("failed to delete core data test file with error \(error)")
        }
    }
    
    // This test case checks to see if the record id of two connected vocabularies is the same as its connection id.
    func testVocabularyConnectionsRecordId() {
        // 1. Create 2 vocaularies
        let mainCollection = VocabularyCollection(name: "English", user: coreData.user())
        
        let sourceVocab = Vocabulary(collection: mainCollection)
        let targetVocab = Vocabulary(collection: mainCollection)
        
        // 2. Add connection between the two
        let connection = sourceVocab.addConnection(with: targetVocab, type: .related)
        
        // 3. Create the IDs of the connection and of the two connected vocabularies
        let connectionId = connection!.recordMetadata.recordName
        let combinedVocabId = "\(sourceVocab.recordMetadata.recordName)+\(targetVocab.recordMetadata.recordName)=\(connection!.type.rawValue)"
        
        // 4. Validate if the IDs are equal to each other
        XCTAssertEqual(connectionId, combinedVocabId, "Source Vocab and Target Vocab doesn't match with connectionID")
    }
    
    // This test case checks to see if a connection between two vocabularies of different collections is not possible.
    func testAddVocabularyConnectionCrossCollection() {
        // 1. Create 2 vocabularies in different collections
        let mainCollection = VocabularyCollection(name: "English", user: coreData.user())
        let otherCollection = VocabularyCollection(name: "Spanish", user: coreData.user())
        
        let vocab1 = Vocabulary(collection: mainCollection)
        let vocab2 = Vocabulary(collection: otherCollection)
        
        // 2. Set a connection between them
        let connection1 = vocab1.addConnection(with: vocab2, type: .alternative)
        
        XCTAssertNil(connection1, "The connection was created. Check the logic of the function.") // nil = not created, !nil = created
    }
    
    // This test case checks to see if a connection is deleted when one of the connected vocabularies is deleted from its collection.
    func testVocabularyConnectionCascadeDelete() {
        // 1. Create 2 vocabularies
        let mainCollection = VocabularyCollection(name: "English", user: coreData.user())
        
        let vocab1 = Vocabulary(collection: mainCollection)
        let vocab2 = Vocabulary(collection: mainCollection)
        
        // 2. Add a connection
        let connection1 = vocab1.addConnection(with: vocab2, type: .alternative)
        
        // 3. Check if connection was created
        XCTAssertNotNil(connection1, "The connection cannot be created.")  // Nil = not created, !nil = created
        
        // 3. Get the record name of connection1
        let recordName = connection1!.recordMetadata.recordName
        
        // 4. Delete the vocabulary
        mainContext.delete(vocab1)
        mainContext.quickSave()
        
        // 5. Create a request of type VocabularyConnection to check if connection still exists
        let request: NSFetchRequest<VocabularyConnection> = VocabularyConnection.fetchRequest()
        request.predicate = NSPredicate(format: "recordMetadata.recordName = %@", recordName) // query to find a record name that matches recordName
        
        // 6. Find the connection with the request using mainContext
        do {
            let result = try mainContext.fetch(request)
            XCTAssertEqual(result.isEmpty, true, "The connection still exists") // Check if connection is still there
        } catch {
            fatalError("Failed to fetch")
        }
    }
}
