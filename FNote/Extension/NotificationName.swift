//
//  NotificationName.swift
//  FNote
//
//  Created by Dara Beng on 9/20/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


extension Notification.Name {
    
    static let appCurrentCollectionDidChange = Notification.Name("Notification.Name.appCurrentCollectionDidChange")
    
    // set notification name for deleting
    static let appCollectionDidDelete =
        Notification.Name("Notification.Name.appCollectionDidDelete")
}


