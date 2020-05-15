//
//  ObjectMigrationPolicyV1V2.swift
//  FNote
//
//  Created by Dara Beng on 5/14/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation
import CoreData


class ObjectMigrationPolicyV1V2: NSEntityMigrationPolicy {
    
    // Note: The migration will be perform using string based names and properties.
    // This is to denote that at this point in time, these are the names and properties.
    
    override func createRelationships(
        forDestination dInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        try super.createRelationships(forDestination: dInstance, in: mapping, manager: manager)
        
        switch dInstance.entity.name {
        
        case "NoteCard":
            handleCreateNoteCardRelationships(dInstance: dInstance, mapping: mapping, manager: manager)
        
        case "NoteCardCollection":
            handleCreateNoteCardCollectionRelationships(dInstance: dInstance, mapping: mapping, manager: manager)
        
        case "Tag":
            handleCreateTagRelationships(dInstance: dInstance, mapping: mapping, manager: manager)
        
        case "NoteCardLinker", "Metadata":
            break
        
        default:
            fatalError("🧨 attempted to migrate unknown entity '\(dInstance.entity.name!)' 🧨")
        }
    }
}


extension ObjectMigrationPolicyV1V2 {
    
    // MARK: Main Helper
    
    func handleCreateNoteCardRelationships(dInstance: NSManagedObject, mapping: NSEntityMapping, manager: NSMigrationManager) {
        // assign metadata
        createMetadata(for: dInstance, in: manager.destinationContext)
        
        // create linker & move relationships to linker's targets
        let linker = createManagedObject(entityName: "NoteCardLinker", in: manager.destinationContext)
        let relationships = dInstance.value(forKey: "relationships") as! NSSet
        linker.setValue(relationships, forKey: "targets")
        
        // assign linker
        dInstance.setValue(linker, forKey: "linker")
    }
    
    func handleCreateNoteCardCollectionRelationships(dInstance: NSManagedObject, mapping: NSEntityMapping, manager: NSMigrationManager) {
        // assign metadata
        createMetadata(for: dInstance, in: manager.destinationContext)
    }
    
    func handleCreateTagRelationships(dInstance: NSManagedObject, mapping: NSEntityMapping, manager: NSMigrationManager) {
        // assign metadata
        createMetadata(for: dInstance, in: manager.destinationContext)
    }
    
    
    // MARK: Utility Helper
    
    /// Assuming key is `metadata` for all kind of object
    func createMetadata(for object: NSManagedObject, in context: NSManagedObjectContext) {
        let metadata = createManagedObject(entityName: "Metadata", in: context)
        metadata.setValue(Date(), forKey: "creationDate")
        metadata.setValue(2, forKey: "version")
        object.setValue(metadata, forKey: "metadata")
    }
    
    func createManagedObject(entityName: String, in context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        let object = NSManagedObject(entity: entity, insertInto: context)
        return object
    }
}
