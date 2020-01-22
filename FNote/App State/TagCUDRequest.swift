//
//  TagCUDRequest.swift
//  FNote
//
//  Created by Dara Beng on 1/22/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation


class TagCUDRequest: ObjectCUDRequest {
    
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func changeContext(_ context: ManagedObjectChildContext) {
        // nothing right now
    }
    
    func update(_ object: Tag) {
        object.name = name
    }
}
