//
//  VocabularyCollection+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 1/21/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


public class VocabularyCollection: NSManagedObject {

    @NSManaged public var name: String
    @NSManaged public var vocabularies: Set<Vocabulary>
    @NSManaged public var createdDate: Date
    @NSManaged public var user: User
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        name = ""
        vocabularies = .init()
        createdDate = .init()
    }
}
