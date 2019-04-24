//
//  VocabularyTests.swift
//  FNoteTests
//
//  Created by Brittney Witts on 4/15/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import XCTest
@testable import FNote
import CoreData


#warning("TODO: fix cannot run all test at once")
class VocabularyTests: XCTestCase {
    
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
    
    // Testing to make sure the Vocab is initializing with empty attributes
    func testVocabInitialization() {
        // 1. Create a new vocab
        let v1 = Vocabulary(context: mainContext)
        
        // 2. Print the starting attributes
        // Testing Native
        XCTAssertEqual(v1.native, "", "Expected to be empty.")
        
        // Testing Translation
        XCTAssertEqual(v1.translation, "", "Expected to be empty.")
        
        // Testing Note
        XCTAssertEqual(v1.note, "", "Expected to be empty.")
        
        // Testing Politeness
        XCTAssertEqual(v1.politeness, .undecided, "Expected to be empty.")
        
        // Testing Relations
        XCTAssertEqual(v1.relations.isEmpty, true, "Expected to be empty.")
        
        // Testing Alternatives
        XCTAssertEqual(v1.alternatives.isEmpty, true, "Expected to be empty.")
        
        // Testing Tags
        XCTAssertEqual(v1.tags.isEmpty, true, "Expected to be empty.")
        
        // Testing Connections
        XCTAssertEqual(v1.connections.isEmpty, true, "Expected to be empty.")
    }
    
    // Testing saving vocabulary without creating a collection first
    func testSaveVocabularyWithoutSettingCollection() {
        // 1. Create a new vocab
        let _ = Vocabulary(context: mainContext)
        
        // 2. Try to save without creating a collection
        XCTAssertThrowsError(try mainContext.save())
    }
    
    // Testing cascade delete of a collection
    func testCascadeDeleteofCollection() {
        // 1. Create 1 Collection
        let testCollection = VocabularyCollection(name: "Testing", user: coreData.user())
        
        // 2. Create 2 vocab inside the collection
        let _ = Vocabulary(collection: testCollection)
        let _ = Vocabulary(collection: testCollection)
        mainContext.quickSave()
        
        // 3. Delete the collection
        mainContext.delete(testCollection)
        mainContext.quickSave()
        
        // 4. Fetch v1 and v2
        let request: NSFetchRequest<Vocabulary> = Vocabulary.fetchRequest() //create a new request of type Vocabulary
        request.predicate = NSPredicate(value: true) //grab all predicate values for the fetch
        
        do {
            let vocabArray = try mainContext.fetch(request) //create an array filled with the fetched data
            
            //the array should be empty since the collection was deleted
            XCTAssertEqual(vocabArray.count, 0, "The vocabulary wasn't cascade deleted.")
            
        } catch {
            fatalError("Something is wrong.")
        }
    }
}
