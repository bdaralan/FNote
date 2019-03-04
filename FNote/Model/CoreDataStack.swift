//
//  CoreDataStack.swift
//  FNote
//
//  Created by Dara Beng on 1/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


class CoreDataStack {
    
    static private(set) var current: CoreDataStack = .init(userAccountToken: CloudKitService.accountToken)
    
    static let coreDataModel: NSManagedObjectModel = {
        let url = Bundle.main.url(forResource: "DataModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: url)!
        return model
    }()
    
    let persistentContainer: NSPersistentContainer
    let mainContext: NSManagedObjectContext
    
    private(set) var userAccountToken: String
    
    init(userAccountToken: String) {
        self.userAccountToken = userAccountToken
        let container = NSPersistentContainer(name: userAccountToken, managedObjectModel: CoreDataStack.coreDataModel)
        let persistentStore = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("\(userAccountToken).sqlite")
        let isPersistentStoreExisted = FileManager.default.fileExists(atPath: persistentStore.path)
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        let coordinator = container.persistentStoreCoordinator
        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStore, options: options)
        persistentContainer = container
        mainContext = persistentContainer.viewContext
        
        #warning("TODO: remove this test code and implenent no account user")
        guard !isPersistentStoreExisted else { return }
        createUser(userRecordIDName: userAccountToken)
    }
    
    func setPersistentStore(forUserAccountToken token: String) {
        CoreDataStack.current = .init(userAccountToken: token)
    }
}


extension CoreDataStack {
    
    #warning("TODO: need real logic")
    func createUser(userRecordIDName: String) {
        let user = User(context: mainContext)
        user.userID = userRecordIDName
        let collection = VocabularyCollection(context: mainContext)
        collection.name = "Sample Collection"
        mainContext.quickSave()
    }
    
    func currentUser() -> User {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(value: true)
        let results = try! mainContext.fetch(request)
        return results.first!
    }

    func vocabularyCollections() -> [VocabularyCollection] {
        let request: NSFetchRequest<VocabularyCollection> = VocabularyCollection.fetchRequest()
        let results = try? mainContext.fetch(request)
        return results ?? []
    }
}
