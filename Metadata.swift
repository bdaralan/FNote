//
//  Metadata+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 5/14/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


class Metadata: NSManagedObject {

    @NSManaged private(set) var creationDate: Date
    @NSManaged private(set) var version: Int64
    
    @NSManaged private var card: NoteCard?
    @NSManaged private var collection: NoteCardCollection?
    @NSManaged private var tag: Tag?
    @NSManaged private var linker: NoteCardLinker?

    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = .init()
        version = 2
    }
}


extension Metadata {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Metadata> {
        return NSFetchRequest<Metadata>(entityName: "Metadata")
    }
}
