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
        
        let objectModelUrl = Bundle.main.url(forResource: "DataModel", withExtension: "momd")!
        let objectModel = NSManagedObjectModel(contentsOf: objectModelUrl)!
        persistentContainer = NSPersistentContainer(name: userAccountToken, managedObjectModel: objectModel)
        try! persistentContainer.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStore, options: options)
        
        #warning("TODO: remove this test code and implenent no account user")
        guard !isPersistentStoreExisted else { return }
        createUser(userRecordIDName: userAccountToken)
    }
    
    func setPersistentStore(userAccountToken: String) {
        CoreDataStack.current = .init(userAccountToken: userAccountToken)
    }
}


extension CoreDataStack {
    
    #warning("TODO: need real logic")
    func createUser(userRecordIDName: String) {
        let user = User(context: mainContext)
        user.userID = userRecordIDName
        let collection = VocabularyCollection(context: mainContext)
        collection.name = "Sample"
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
