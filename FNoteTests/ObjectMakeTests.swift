//
//  ObjectMakeTests.swift
//  FNoteTests
//
//  Created by Dara Beng on 5/17/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import XCTest
@testable import FNote


class ObjectMakeTests: XCTestCase {

    func testImportPublicCollection() {
        let importContext = CoreDataStack.current.mainContext.newChildContext()
        let objectMaker = ObjectMaker(context: importContext)
        
        let publicCollection = makeMockPublicCollection()
        let publicCards = makeMockPublicCards(collection: publicCollection)
        
        let collection = objectMaker.makeNoteCardCollection(name: publicCollection.name, with: publicCards)
        
        // assert collection
        XCTAssertEqual(collection.name, publicCollection.name)
        XCTAssertEqual(collection.noteCards.count, publicCollection.cardsCount)
        
        // assert collection's cards
        XCTAssertNotNil(collection.noteCards.first(where: { $0.native == "N01" }))
        XCTAssertNotNil(collection.noteCards.first(where: { $0.native == "N02" }))
        XCTAssertNotNil(collection.noteCards.first(where: { $0.native == "N03" }))
        XCTAssertNotNil(collection.noteCards.first(where: { $0.native == "N04" }))
        
        let card01 = collection.noteCards.first(where: { $0.native == "N01" })!
        let card02 = collection.noteCards.first(where: { $0.native == "N02" })!
        let card03 = collection.noteCards.first(where: { $0.native == "N03" })!
        let card04 = collection.noteCards.first(where: { $0.native == "N04" })!
        
        // assert card native, translation, note
        let allCards = [card01, card02, card03, card04]
        XCTAssertEqual(allCards.count, 4)
        
        for (index, card) in allCards.enumerated() {
            let number = index + 1
            XCTAssertEqual(card.native, "N0\(number)")
            XCTAssertEqual(card.translation, "T0\(number)")
            XCTAssertEqual(card.note, "note0\(number)")
        }
        
        // assert card favorited
        XCTAssertEqual(card01.isFavorite, true)
        XCTAssertEqual(card02.isFavorite, false)
        XCTAssertEqual(card03.isFavorite, true)
        XCTAssertEqual(card04.isFavorite, false)
        
        // assert card formality
        XCTAssertEqual(card01.formality, .unspecified)
        XCTAssertEqual(card02.formality, .informal)
        XCTAssertEqual(card03.formality, .neutral)
        XCTAssertEqual(card04.formality, .formal)
        
        // assert card tags
        let allTags = Set(allCards.flatMap(\.tags))
        XCTAssertEqual(allTags.count, 4)
        
        XCTAssertNotNil(allTags.first(where: { $0.name == "t01" }))
        XCTAssertNotNil(allTags.first(where: { $0.name == "t02" }))
        XCTAssertNotNil(allTags.first(where: { $0.name == "t03" }))
        XCTAssertNotNil(allTags.first(where: { $0.name == "t04" }))
        
        let tag01 = allTags.first(where: { $0.name == "t01" })!
        let tag02 = allTags.first(where: { $0.name == "t02" })!
        let tag03 = allTags.first(where: { $0.name == "t03" })!
        let tag04 = allTags.first(where: { $0.name == "t04" })!
        
        for tag in [tag01, tag02, tag03, tag04] {
            XCTAssertTrue(card01.tags.contains(tag))
        }
        
        for tag in [tag02, tag03, tag04] {
            XCTAssertTrue(card02.tags.contains(tag))
        }
        
        for tag in [tag03, tag04] {
            XCTAssertTrue(card03.tags.contains(tag))
        }
        
        XCTAssertTrue(card04.tags.contains(tag04))
        
        XCTAssertFalse(card02.tags.contains(tag01))
        
        XCTAssertFalse(card03.tags.contains(tag01))
        XCTAssertFalse(card03.tags.contains(tag02))
        
        XCTAssertFalse(card04.tags.contains(tag01))
        XCTAssertFalse(card04.tags.contains(tag02))
        XCTAssertFalse(card04.tags.contains(tag03))
        
        // assert card relationships
        XCTAssertTrue(card01.linker.targets.contains(card04))
        XCTAssertTrue(card01.linker.targets.contains(card02))
        XCTAssertFalse(card01.linker.targets.contains(card01))
        XCTAssertFalse(card01.linker.targets.contains(card03))
        
        XCTAssertTrue(card02.linker.targets.contains(card01))
        XCTAssertTrue(card02.linker.targets.contains(card03))
        XCTAssertFalse(card02.linker.targets.contains(card02))
        XCTAssertFalse(card02.linker.targets.contains(card04))
        
        XCTAssertTrue(card03.linker.targets.contains(card02))
        XCTAssertTrue(card03.linker.targets.contains(card04))
        XCTAssertFalse(card03.linker.targets.contains(card01))
        XCTAssertFalse(card03.linker.targets.contains(card03))
        
        XCTAssertTrue(card04.linker.targets.contains(card03))
        XCTAssertTrue(card04.linker.targets.contains(card01))
        XCTAssertFalse(card04.linker.targets.contains(card02))
        XCTAssertFalse(card04.linker.targets.contains(card04))
    }
    
    
    // MARK: Helper
    
    func makeMockPublicCollection() -> PublicCollection {
        PublicCollection(
            collectionID: UUID().uuidString,
            authorID: UUID().uuidString,
            authorName: "mock user",
            name: "mock collection",
            description: "mock description",
            primaryLanguageCode: "kor",
            secondaryLanguageCode: "en",
            tags: ["some", "mock", "tag"],
            cardsCount: 4
        )
    }
    
    func makeMockPublicCards(collection: PublicCollection) -> [PublicCard] {
        let card01 = PublicCard(
            collectionID: collection.collectionID,
            cardID: "cardID01",
            native: "N01",
            translation: "T01",
            favorited: true,
            formality: .unspecified,
            note: "note01",
            tags: ["t01", "t02", "t03", "t04"],
            relationships: ["cardID04", "cardID02"]
        )
        
        let card02 = PublicCard(
            collectionID: collection.collectionID,
            cardID: "cardID02",
            native: "N02",
            translation: "T02",
            favorited: false,
            formality: .informal,
            note: "note02",
            tags: ["t02", "t03", "t04"],
            relationships: ["cardID01", "cardID03"]
        )
        
        let card03 = PublicCard(
            collectionID: collection.collectionID,
            cardID: "cardID03",
            native: "N03",
            translation: "T03",
            favorited: true,
            formality: .neutral,
            note: "note03",
            tags: ["t03", "t04"],
            relationships: ["cardID02", "cardID04"]
        )
        
        let card04 = PublicCard(
            collectionID: collection.collectionID,
            cardID: "cardID04",
            native: "N04",
            translation: "T04",
            favorited: false,
            formality: .formal,
            note: "note04",
            tags: ["t04"],
            relationships: ["cardID03", "cardID01"]
        )
        
        return [card01, card02, card03, card04]
    }
}
