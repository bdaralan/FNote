//
//  FNoteTests.swift
//  FNoteTests
//
//  Created by Dara Beng on 3/12/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import XCTest
import CoreData
@testable import FNote


class FNoteTests: XCTestCase {
    
    var coreData: CoreDataStack!
    var mainContext: NSManagedObjectContext!

    override func setUp() {
        coreData = CoreDataStack(userAccountToken: "user-test-account-token")
        mainContext = coreData.mainContext
    }

    override func tearDown() {
        try! FileManager.default.removeItem(at: coreData.persistentStoreUrl)
        coreData = nil
        mainContext = nil
    }
}
