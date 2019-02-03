//
//  CoreDataStack.swift
//  FNote
//
//  Created by Dara Beng on 1/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


class CoreDataStack {
    
    #warning("TODO: need logic to get current user's iCloud account id")
    static private(set) var current: CoreDataStack = .init(userRecordIDName: CloudKitService.current.userRecordIDName)
    
    static let coreDataModel: NSManagedObjectModel = {
        let url = Bundle.main.url(forResource: "DataModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: url)!
        return model
    }()
    
    let persistentContainer: NSPersistentContainer
    let mainContext: NSManagedObjectContext
    
    init(userRecordIDName: String) {
        let container = NSPersistentContainer(name: userRecordIDName, managedObjectModel: CoreDataStack.coreDataModel)
        let persistentStore = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("\(userRecordIDName).sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        let coordinator = container.persistentStoreCoordinator
        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStore, options: options)
        persistentContainer = container
        mainContext = persistentContainer.viewContext
        
        guard fetchUser(userRecordIDName: userRecordIDName) == nil else { return }
        createNewUser(userRecordIDName: userRecordIDName)
    }
    
    func changePersistentStore(forUserRecordIDName name: String) {
        CoreDataStack.current = .init(userRecordIDName: name)
    }
}


extension CoreDataStack {
    
    #warning("TODO: need real logic")
    func createNewUser(userRecordIDName: String) {
        let user = User(context: mainContext)
        user.userID = userRecordIDName
        let collection = VocabularyCollection(context: mainContext)
        collection.name = "Korean"
        mainContext.quickSave()
    }
    
    func fetchUser(userRecordIDName: String) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %@", userRecordIDName)
        let results = try? mainContext.fetch(request)
        return results?.first
    }
    
    func currentUser() -> User? {
        return fetchUser(userRecordIDName: CloudKitService.current.userRecordIDName)
    }
    
    #warning("test func")
    func firstCollection() -> VocabularyCollection? {
        let request: NSFetchRequest<VocabularyCollection> = VocabularyCollection.fetchRequest()
        let results = try? mainContext.fetch(request)
        return results?.first
    }
}


extension NSManagedObjectContext {
    
    func quickSave() {
        do {
            guard hasChanges else { return }
            try save()
        } catch {
            fatalError("quickSave() failed!!!")
        }
    }
}
