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


class Tag: NSManagedObject, Identifiable, ObjectValidatable {
    
    @NSManaged private(set) var uuid: String
    @NSManaged var name: String
    @NSManaged var noteCards: Set<NoteCard>
    
    
    convenience init(uuid: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.uuid = uuid
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        uuid = UUID().uuidString
    }
    
    override func willSave() {
        if !isDeleted {
            validateData()
        }
        super.willSave()
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
    
    func setName(_ string: String) {
        modifiedObject.setName(string)
    }
}


extension Tag {
    
    func isValid() -> Bool {
        hasValidInputs()
    }
    
    func hasValidInputs() -> Bool {
        !name.trimmed().isEmpty
    }
    
    func hasChangedValues() -> Bool {
        hasPersistentChangedValues
    }
    
    func validateData() {
        let name = self.name.trimmedComma().lowercased()
        setPrimitiveValue(name, forKey: #keyPath(Tag.name))
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
