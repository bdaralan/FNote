//
//  CoreDataStack.swift
//  FNote
//
//  Created by Dara Beng on 1/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


class CoreDataStack {
    
    static private(set) var current = CoreDataStack(userAccountToken: CloudKitService.accountToken)
    
    static let objectModel: NSManagedObjectModel = {
        let url = Bundle.main.url(forResource: "DataModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: url)!
        return model
    }()
    
    let persistentContainer: NSPersistentContainer
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private(set) var userAccountToken: String
    
    
    init(userAccountToken: String) {
        self.userAccountToken = userAccountToken

        let persistentStore = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("\(userAccountToken).sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        let isPersistentStoreExisted = FileManager.default.fileExists(atPath: persistentStore.path)
        
        persistentContainer = NSPersistentContainer(name: userAccountToken, managedObjectModel: CoreDataStack.objectModel)
        try! persistentContainer.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStore, options: options)
        
        if isPersistentStoreExisted {
            createSampleVocabulryCollectionIfNeeded()
        } else {
            setupUserProfile(accountToken: userAccountToken)
        }
    }
    
    func setPersistentStore(userAccountToken: String) {
        guard self.userAccountToken != userAccountToken else { return }
        CoreDataStack.current = CoreDataStack(userAccountToken: userAccountToken)
    }
}


extension CoreDataStack {
    
    /// Create user profile on first time load.
    func setupUserProfile(accountToken: String) {
        let context = mainContext
        let user = User(accountToken: accountToken, context: context)
        createSampleVocabularyCollection(for: user)
        context.quickSave()
    }
    
    /// Fetch the current user from the given context.
    /// The main context is used, if the given context is `nil`.
    func currentUser(context: NSManagedObjectContext? = nil) -> User {
        let context = context ?? mainContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(value: true)
        let results = try! context.fetch(request)
        return results.first!
    }

    func userVocabularyCollections() -> [VocabularyCollection] {
        let request: NSFetchRequest<VocabularyCollection> = VocabularyCollection.fetchRequest()
        let results = try? mainContext.fetch(request)
        return results ?? []
    }
    
    func fetchVocabularyCollection(recordName: String, context: NSManagedObjectContext) -> VocabularyCollection? {
        let request: NSFetchRequest<VocabularyCollection> = VocabularyCollection.fetchRequest()
        request.predicate = NSPredicate(format: "recordMetadata.recordName == %@", recordName)
        let collections = try? context.fetch(request)
        return collections?.first
    }
    
    func createSampleVocabularyCollection(for user: User) {
        guard let context = user.managedObjectContext else { return }
        let collection = VocabularyCollection(context: context)
        collection.name = "My Collection"
    }
    
    private func createSampleVocabulryCollectionIfNeeded() {
        guard userVocabularyCollections().isEmpty else { return }
        createSampleVocabularyCollection(for: currentUser())
        mainContext.quickSave()
    }
}
