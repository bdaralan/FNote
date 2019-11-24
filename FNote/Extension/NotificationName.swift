//
//  NotificationName.swift
//  FNote
//
//  Created by Dara Beng on 9/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


// MARK: - App

extension Notification.Name {
    
    /// A notification name for changing current collection.
    /// - Important: Must pass in the collection to the notification's object.
    static let appCurrentCollectionDidChange = Notification.Name("Notification.Name.appCurrentCollectionDidChange")
    
    /// A notification name for deleting a collection.
    /// - Important: Must pass in the collection's UUID to the notification's object.
    static let appCollectionDidDelete = Notification.Name("Notification.Name.appCollectionDidDelete")
    
    // set notification name for deleting a tag
    static let appCurrentTagDidDelete = Notification.Name("Notification.Name.appCurrentTagDidDelete")
    
    /// A notification name for requesting `NoteCardCollectionView` to display the card.
    /// - Important: Must pass in the note card to the notification's object.
    static let requestDisplayingNoteCard = Notification.Name("Notification.Name.requestDisplayingNoteCard")
}


// MARK: - Core Data Stack

extension Notification.Name {
    
    /// A notification name for remote store values change.
    static let persistentStoreRemoteChange = Notification.Name("NSPersistentStoreRemoteChangeNotification")
}

