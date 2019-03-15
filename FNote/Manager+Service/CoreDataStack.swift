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

        let persistentStoreUrl = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("\(userAccountToken).sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        let isPersistentStoreExisted = FileManager.default.fileExists(atPath: persistentStoreUrl.path)
        
        persistentContainer = NSPersistentContainer(name: userAccountToken, managedObjectModel: CoreDataStack.objectModel)
        try! persistentContainer.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreUrl, options: options)
        
        guard isPersistentStoreExisted == false else { return }
        setupUserProfile(accountToken: userAccountToken)
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
        user.managedObjectContext?.quickSave()
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

    /// Fetch vocabulary collections from the given context. If `nil`, the default main context is used.
    func fetchVocabularyCollections(from context: NSManagedObjectContext? = nil) -> [VocabularyCollection] {
        let context = context ?? mainContext
        let request: NSFetchRequest<VocabularyCollection> = VocabularyCollection.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let results = try? context.fetch(request)
        return results ?? []
    }
    
    func fetchVocabularyCollection(recordName: String, context: NSManagedObjectContext) -> VocabularyCollection? {
        let request: NSFetchRequest<VocabularyCollection> = VocabularyCollection.fetchRequest()
        request.predicate = NSPredicate(format: "recordMetadata.recordName == %@", recordName)
        let collections = try? context.fetch(request)
        return collections?.first
    }
}
