//
//  Tag+CoreDataClass.swift
//  FNote
//
//  Created by Dara Beng on 9/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//

import Foundation
import CoreData


class Tag: NSManagedObject {
    
    @NSManaged private(set) var uuid: String
    @NSManaged private(set) var name: String
    @NSManaged private(set) var noteCards: Set<NoteCard>
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        uuid = UUID().uuidString
    }
}


// MARK: - Setter

extension Tag {
    
    fileprivate func setName(_ string: String) {
        name = string.trimmed()
    }
}


// MARK: - Object Modifier Setter

extension ObjectModifier where Object == Tag {
    
    var name: String {
        set { modifiedObject.setName(newValue) }
        get { modifiedObject.name }
    }
}

extension Tag {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }
    
    static func requestAllTags() -> NSFetchRequest<Tag> {
        let request = Tag.fetchRequest() as NSFetchRequest<Tag>
        let nameField = #keyPath(Tag.name)
        request.predicate = .init(value: true)
        request.sortDescriptors = [.init(key: nameField, ascending: true)]
        return request
    }
}


extension Collection where Element == Tag {
    
    func sortedByName() -> [Tag] {
        self.sorted(by: { $0.name < $1.name })
    }
}
