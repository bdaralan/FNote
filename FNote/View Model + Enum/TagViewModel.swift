//
//  TagViewModel.swift
//  FNote
//
//  Created by Dara Beng on 9/28/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


struct TagViewModel: Identifiable, Equatable {
    var id: String { uuid }
    let uuid: String
    var name: String
}


extension TagViewModel {
    
    init(tag: Tag) {
        uuid = tag.uuid
        name = tag.name
    }
}


extension Array where Element == TagViewModel {
    
    mutating func sortByName() {
        sort(by: { $0.name < $1.name })
    }
}
