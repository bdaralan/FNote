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
    
    // set notification name for selecting a collection
    static let appCurrentCollectionDidChange = Notification.Name("Notification.Name.appCurrentCollectionDidChange")
    
    // set notification name for deleting a collection
    static let appCollectionDidDelete = Notification.Name("Notification.Name.appCollectionDidDelete")
    
    // set notification name for deleting a tag
    static let appCurrentTagDidDelete = Notification.Name("Notification.Name.appCurrentTagDidDelete")
    
    /// Set notification name for requesting NoteCardCollectioView to display the card details
    /// - Important: the notification must pass in a NoteCard object
    static let requestDisplayingNoteCardDetail = Notification.Name("Notification.Name.requestDisplayingNoteCardDetail")
}


// MARK: - Core Data Stack

extension Notification.Name {
    
    /// A notification name for remote store values change.
    static let persistentStoreRemoteChange = Notification.Name("NSPersistentStoreRemoteChangeNotification")
}

