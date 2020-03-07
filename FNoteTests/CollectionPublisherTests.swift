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
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    let context = CoreDataStack.current.mainContext.newChildContext()
    var publishedCount = 0

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

    func testUploadCollection() {
        let publicCollection = createPublishCollection()
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
        
        let publicCards = cards.map { card in
            PublicNoteCard(
                collectionID: publicCollection.collectionID,
                cardID: card.uuid,
                native: card.native,
                translation: card.translation,
                favorited: card.isFavorite,
                formality: Int(card.formality.rawValue),
                note: card.note,
                tags: card.tags.map({ $0.name }),
                relationships: card.relationships.map({ $0.uuid })
            )
        }
        
        let waitAsyncCall = self.expectation(description: "waitAsyncCall")
        
        let uploader = PublicCollectionUploader()
        uploader.upload(collection: publicCollection, with: publicCards) { result in
            switch result {
                
            case .success(let (collectionRecord, cardRecords)):
                XCTAssertEqual(collectionRecord.recordID.recordName, publicCollection.collectionID)
                let cardIDs = Set(cards.map({ $0.uuid }))
                for record in cardRecords {
                    XCTAssertTrue(cardIDs.contains(record.recordID.recordName))
                }
            
            default:
                fatalError()
            }
            
            waitAsyncCall.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDownloadCards() {
        testUploadCollection()
        wait(for: [], timeout: 3)
        
        let collection = createPublishCollection()
        let downloader = PublicCollectionDownloader()
        downloader.downloadCards(collectionID: collection.collectionID) { result in
            switch result {
            case .success(let cardRecords):
                XCTAssertEqual(cardRecords.count, 9)
            default:
                fatalError()
            }
        }
    }
    
    func testUploadPublicUser() {
        let waitUpload = expectation(description: "upload")
        let user = PublicUser(userID: "bd-author-id-01", username: "Dara", about: "Admin")
        
        let record = user.createCKRecord()
        publicDatabase.save(record) { record, error in
            if error == nil {
                waitUpload.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testPublishManyCollections() {
        let waitUpload = expectation(description: "upload")
        
        let authorID = "bd-author-id-01"
        for collectionID in 1...20 {
            
            let collectionPID = "PCOID-\(collectionID)"
            
            var cards = [PublicNoteCard]()
            
            for cardID in 1...Int.random(in: 4...10) {
                let cardPID = "\(collectionPID)-PCAID-\(cardID)"
                let card = PublicNoteCard(
                    collectionID: collectionPID,
                    cardID: cardPID,
                    native: "Native \(cardID)",
                    translation: "Translation \(cardID)",
                    favorited: cardID.isMultiple(of: 2),
                    formality: cardID % 4,
                    note: "note for cardID \(cardID)",
                    tags: ["CT \(cardID)", "CT \(cardID + 1)"],
                    relationships: cardID == 1 ? [] : ["PCAID-\(cardID - 1)"]
                )
                cards.append(card)
            }
            
            let collection = PublicCollection(
                collectionID: collectionPID,
                authorID: authorID,
                name: "PCName \(collectionID)",
                description: "PCDescription \(collectionID)",
                primaryLanguage: String(format: "P%02d", collectionID),
                secondaryLanguage: String(format: "S%02d", collectionID),
                tags: ["T \(collectionID)", "T \(collectionID + 1)", "T \(collectionID + 2)"],
                cardsCount: cards.count
            )
            
            let uploader = PublicCollectionUploader()
            uploader.upload(collection: collection, with: cards) { result in
                if case .success = result {
                    self.publishedCount += 1
                }
                
                if self.publishedCount == 20 {
                    waitUpload.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 30)
    }
    
    func createPublishCollection() -> PublicCollection {
        PublicCollection(
            collectionID: "collection.uuid",
            authorID: "testAuthorID",
            name: "Collection Name",
            description: "Description",
            primaryLanguage: "PRI",
            secondaryLanguage: "SEC",
            tags: ["Tag 01", "Tag 02", "Tag 03"],
            cardsCount: 49
        )
    }
}
