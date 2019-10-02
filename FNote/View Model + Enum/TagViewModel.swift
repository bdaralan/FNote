//
//  TagViewModel.swift
//  FNote
//
//  Created by Dara Beng on 9/28/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


struct TagViewModel {
    let uuid: String
    var name: String
    
    init(uuid: String = UUID().uuidString, name: String = "") {
        self.uuid = uuid
        self.name = name
    }
    
    init(tag: Tag) {
        self.init(uuid: tag.uuid, name: tag.name)
    }
}


extension Array where Element == TagViewModel {
    
    mutating func sortByName() {
        sort(by: { $0.name < $1.name })
    }
    
    func sortedByName() -> [Element] {
        sorted(by: { $0.name < $1.name })
    }
}
