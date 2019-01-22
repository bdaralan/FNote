//
//  CoreDataStack.swift
//  FNote
//
//  Created by Dara Beng on 1/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


class CoreDataStack {
    
    static private(set) var current: CoreDataStack = {
        #warning("TODO: need logic to get current user's iCloud account id")
        let icloudToken = "bdaralan"
        let stack = CoreDataStack(icloudToken: icloudToken)
        return stack
    }()
    
    static let coreDataModel: NSManagedObjectModel = {
        let url = Bundle.main.url(forResource: "DataModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: url)!
        return model
    }()
    
    
    let icloudToken: String
    
    let persistentContainer: NSPersistentContainer
    let mainContext: NSManagedObjectContext
    
    init(icloudToken: String) {
        self.icloudToken = icloudToken
        let container = NSPersistentContainer(name: icloudToken, managedObjectModel: CoreDataStack.coreDataModel)
        let persistentStore = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("\(icloudToken).sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        let coordinator = container.persistentStoreCoordinator
        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStore, options: options)
        persistentContainer = container
        mainContext = persistentContainer.viewContext
    }
    
    #warning("TODO: need real logic")
    private(set) lazy var user: User = {
        guard let user = getUser(icloudToken: icloudToken) else {
            let newUser = User(context: mainContext)
            newUser.userID = icloudToken
            let collection = VocabularyCollection(context: mainContext)
            collection.name = "Korean"
            collection.user = newUser
            mainContext.quickSave()
            return newUser
        }
        return user
    }()
    
    private func getUser(icloudToken: String) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %@", icloudToken)
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
