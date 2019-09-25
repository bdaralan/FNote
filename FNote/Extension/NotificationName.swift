//
//  NotificationName.swift
//  FNote
//
//  Created by Dara Beng on 9/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


extension Notification.Name {
    
    // set notification name for selecting a collection
    static let appCurrentCollectionDidChange = Notification.Name("Notification.Name.appCurrentCollectionDidChange")
    
    // set notification name for deleting a collection
    static let appCollectionDidDelete =
        Notification.Name("Notification.Name.appCollectionDidDelete")
    
    // set notification name for deleting a tag
    static let appCurrentTagDidDelete = Notification.Name("Notificiation.Name.appCurrentTagDidDelete")
}


