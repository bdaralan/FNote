//
//  IndexPathList.swift
//  FNote
//
//  Created by Dara Beng on 1/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


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


extension IndexPathList where S: Equatable, I: Equatable {
    
    func indexPath(for item: I) -> IndexPath? {
        for (sectionIndex, section) in elements.enumerated() where section.items.contains(item) {
            for (itemIndex, sectionItem) in section.items.enumerated() where sectionItem == item {
                return IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
        return nil
    }
}


extension IndexPathList {
    
    struct Item<S, I> {
        let section: S
        let items: [I]
    }
}
