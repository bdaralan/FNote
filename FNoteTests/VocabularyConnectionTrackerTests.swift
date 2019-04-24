//
//  VocabularyConnectionTrackerTests.swift
//  FNoteTests
//
//  Created by Dara Beng on 4/23/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import XCTest
import CoreData
@testable import FNote


class VocabularyConnectionTrackerTests: XCTestCase {
    
    var coreData: CoreDataStack {
        return CoreDataStack.current
    }
    
    var mainContext: NSManagedObjectContext {
        return CoreDataStack.current.mainContext
    }

    
    override func setUp() {
        let testAccountToken = UUID().uuidString // a random-unique string
        coreData.setPersistentStore(userAccountToken: testAccountToken)
    }

    override func tearDown() {
        do {
            try FileManager.default.removeItem(at: coreData.persistentStoreUrl)
        } catch {
            fatalError("failed to delete core data test file with error \(error)")
        }
    }

    // Test contructor to see if it assign initial values correctly.
    func testConstructorInitialValues() {
        let user = coreData.user()
        let collection = VocabularyCollection(name: "Tracker", user: user)
        
        let sourceVocab = Vocabulary(collection: collection)
        
        let tracker = VocabularyConnectionTracker(vocabulary: sourceVocab)
        
        XCTAssertEqual(tracker.vocabulary, sourceVocab)
        
        // check for connected vocabularies
        for connectionType in VocabularyConnection.ConnectionType.allCases {
            XCTAssertTrue(tracker.trackedVocabularies(for: connectionType).isEmpty, "initial value should be empty")
            XCTAssertEqual(tracker.trackerDictionary[connectionType]?.isEmpty, true, "initial value should be empty")
        }
    }

    // Test the track method by adding target vocabularies.
    // One from the same collection and the other from a different collection.
    func testTrackVocabularyMethod() {
        let user = coreData.user()
        
        // try to track a vocabulary in the same collection
        let englishCollection = VocabularyCollection(name: "English", user: user)
        
        let sourceVocab = Vocabulary(collection: englishCollection)
        let targetVocab = Vocabulary(collection: englishCollection)
        
        let tracker = VocabularyConnectionTracker(vocabulary: sourceVocab)
        var relatedVocabularies: Set<Vocabulary> // a set used to check result
        
        tracker.trackVocabulary(targetVocab, connectionType: .related)
        relatedVocabularies = tracker.trackedVocabularies(for: .related)
        
        XCTAssertEqual(relatedVocabularies.count, 1, "there should be 1 vocabulary tracked")
        
        // try to track a vocabulary in different collection
        let koreanCollection = VocabularyCollection(name: "Korean", user: user)
        let targetVocabInKoreanCollection = Vocabulary(collection: koreanCollection)
        
        tracker.trackVocabulary(targetVocabInKoreanCollection, connectionType: .related)
        relatedVocabularies = tracker.trackedVocabularies(for: .related)
        
        XCTAssertEqual(relatedVocabularies.count, 1, "there should still be 1 vocabulary tracked")
    }
    
    // Test the remove method by adding a vocabulary then remove it.
    func testRemoveTrackedVocabularyMethod() {
        let user = coreData.user()
        let collection = VocabularyCollection(name: "Test", user: user)
        
        let sourceVocab = Vocabulary(collection: collection)
        let targetVocab = Vocabulary(collection: collection)
        
        let tracker = VocabularyConnectionTracker(vocabulary: sourceVocab)
        
        tracker.trackVocabulary(targetVocab, connectionType: .alternative)
        
        XCTAssertEqual(tracker.trackedVocabularies(for: .alternative).count, 1, "tracker didn't track the target vocabulary")
        
        tracker.removeTrackedVocabulary(targetVocab, connectionType: .alternative)
        
        XCTAssertEqual(tracker.trackedVocabularies(for: .alternative).count, 0, "tracker didn't remove the target vocabulary")
    }
}
