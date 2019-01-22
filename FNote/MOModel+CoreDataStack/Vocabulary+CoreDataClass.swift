//
//  Vocabulary+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 1/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


public class Vocabulary: NSManagedObject {

    @NSManaged public var native: String
    @NSManaged public var translation: String
    @NSManaged public var note: String
    @NSManaged public var politeness: String
    @NSManaged public var isFavorited: Bool
    @NSManaged public var relations: Set<Vocabulary>
    @NSManaged public var alternatives: Set<Vocabulary>
    @NSManaged public var collection: VocabularyCollection
    @NSManaged public var createdDate: Date
    
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        native = ""
        translation = ""
        note = ""
        politeness = Politeness.unknown.rawValue
        relations = .init()
        alternatives = .init()
        createdDate = .init()
    }
    
    #warning("TODO: need init that has to set collection")
}


extension Vocabulary {
    
    enum Politeness: String, CaseIterable {
        case unknown = "Unknown"
        case informal = "Informal"
        case neutral = "Neutral"
        case formal = "Formal"
    }
}
