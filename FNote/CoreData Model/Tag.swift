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
    
    @NSManaged fileprivate(set) var metadata: Metadata
    
    @NSManaged fileprivate(set) var uuid: String
    @NSManaged fileprivate(set) var name: String
    @NSManaged fileprivate(set) var noteCards: Set<NoteCard>
    
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        uuid = UUID().uuidString
        metadata = .init(context: managedObjectContext!)
    }
}


extension Tag {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }
    
    static func requestAllTags() -> NSFetchRequest<Tag> {
        let request = Tag.fetchRequest() as NSFetchRequest<Tag>
        let nameField = #keyPath(Tag.name)
        let versionField = #keyPath(Tag.metadata.version)
        request.predicate = .init(format: "\(versionField) > \(Metadata.previousVersion)")
        request.sortDescriptors = [.init(key: nameField, ascending: true)]
        return request
    }
}


// MARK: - Object Modifier Setter

extension ObjectModifier where Object == Tag {
    
    var name: String {
        set { modifiedObject.name = newValue.trimmed() }
        get { modifiedObject.name }
    }
}
