//
//  CollectionPublisherTests.swift
//  FNoteTests
//
//  Created by Dara Beng on 2/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import XCTest
import CloudKit
@testable import FNote


class CollectionPublisherTests: XCTestCase {
    
    let database = CKContainer.default().publicCloudDatabase
    let context = CoreDataStack.current.mainContext.newChildContext()

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testPublish() {
        let collection = NoteCardCollection(context: context)
        collection.name = "Public Collection"
        
        var cards = [NoteCard]()
        
        for i in 1...9 {
            let card = NoteCard(context: context)
            card.native = "N \(i)"
            card.translation = "T \(i)"
            card.isFavorite = i.isMultiple(of: 2)
            card.note = "some note \(i)"
            card.formality = NoteCard.Formality.allCases.randomElement()!
            cards.append(card)
            
            if let randomCard = cards.randomElement() {
                card.addRelationships([randomCard])
            }
        }
        
        let publishCollection = PublishedCollection(
            publishedID: "CPID.\(collection.uuid)",
            publishedDate: Date(),
            authorID: "testAuthorID",
            author: "testAuthor",
            name: collection.name,
            description: "Test 101",
            languages: ["Swift", "Xcode"],
            tags: ["CloudKit"]
        )
        
        let waitAsyncCall = self.expectation(description: "waitAsyncCall")
        
        let publisher = CollectionPublisher(collection: publishCollection, cards: cards)
        publisher.publish(to: database) { savedRecords in
            XCTAssertNotNil(savedRecords)
            waitAsyncCall.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
