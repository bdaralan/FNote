//
//  IndexPathList.swift
//  FNote
//
//  Created by Dara Beng on 1/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


//class IndexPathList<S, I> {
//    var section: S
//    var items: [I]
//
//    init(section: S, items: [I]) {
//        self.section = section
//        self.items = items
//    }
//}

struct IndexPathList<S, I> {
    
    private(set) var elements: [Item<S, I>]
    
    init(elements: [Item<S, I>] = []) {
        self.elements = elements
    }
    
    var count: Int {
        return elements.count
    }
    
    subscript(index: Int) -> Item<S, I> {
        return elements[index]
    }
    
    mutating func addElement(_ item: Item<S, I>) {
        elements.append(item)
    }
}


extension IndexPathList {
    
    struct Item<S, I> {
        let section: S
        let items: [I]
    }
}
