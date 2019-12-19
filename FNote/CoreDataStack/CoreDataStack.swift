//
//  CoreDataStack.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//
//  reference: https://developer.apple.com/documentation/coredata/consuming_relevant_store_changes

import CoreData


/// The core data stack that manages user's object graph.
class CoreDataStack: NSObject {
    
    static private(set) var current = CoreDataStack()
    
    
    let persistentContainer: NSPersistentContainer
    
    let historyTracker: CoreDataStackHistoryTracker
    
    var mainContext: NSManagedObjectContext {
        // auto merge new changes when store gets new updates
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    
    private override init() {
        // use CloudKit container
        persistentContainer = NSPersistentCloudKitContainer(name: "FNote")
        
        // turn on history tracking and listen to remote change notification
        let storeDescription = persistentContainer.persistentStoreDescriptions.first!
        let enabled = NSNumber(value: true)
        storeDescription.setOption(enabled, forKey: "NSPersistentHistoryTrackingKey")
        storeDescription.setOption(enabled, forKey: "NSPersistentStoreRemoteChangeNotificationOptionKey")
        
        // load container
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error { fatalError("could not load persistent store with error: \(error)") }
        }
        
        historyTracker = CoreDataStackHistoryTracker(historyTokenDataKey: "CoreDataStack.HistoryTracker")
        
        super.init()
        AppCache.ubiquityIdentityToken = FileManager.default.ubiquityIdentityToken
        setupUserIdentityChangeNotification()
        
        // delete old history
        if let lastToken = historyTracker.lastToken {
            historyTracker.deleteHistory(before: lastToken, context: mainContext)
        }
    }
}


// MARK: - Handle Identity Changed

extension CoreDataStack {
    
    static let nCoreDataStackDidChange = Notification.Name("CoreDataStack.nCoreDataStackDidChange")
    
    
    func setupUserIdentityChangeNotification() {
        let notificationCenter = NotificationCenter.default
        let notification = Notification.Name.NSUbiquityIdentityDidChange
        let handler = #selector(userIdentifyChanged(_:))
        notificationCenter.addObserver(self, selector: handler, name: notification, object: nil)
    }
    
    @objc func userIdentifyChanged(_ notification: Notification) {
        let cachedToken = AppCache.ubiquityIdentityToken
        let currentToken = FileManager.default.ubiquityIdentityToken
        
        // update cache
        if currentToken == nil {
            AppCache.ubiquityIdentityToken = nil
        } else {
            AppCache.ubiquityIdentityToken = currentToken
        }
        
        switch (cachedToken == nil, currentToken == nil) {
            
        case (false, true), (true, false):
            reloadCoreDataStore()
            
        case (false, false) where !cachedToken!.isEqual(currentToken!):
            reloadCoreDataStore()
            
        default: break
        }
    }
    
    func reloadCoreDataStore() {
        CoreDataStack.current = CoreDataStack()
        NotificationCenter.default.post(name: CoreDataStack.nCoreDataStackDidChange, object: nil)
    }
}
