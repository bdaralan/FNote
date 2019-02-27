//
//  ManagedObjectContext.swift
//  FNote
//
//  Created by Dara Beng on 2/15/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


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
