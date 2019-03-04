//
//  IndexPathSections.swift
//  FNote
//
//  Created by Dara Beng on 1/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


struct IndexPathSections<S, I> {
    
    private(set) var sections: [Section<S, I>]
    
    init(sections: [Section<S, I>] = []) {
        self.sections = sections
    }
    
    var count: Int {
        return sections.count
    }
    
    subscript(index: Int) -> Section<S, I> {
        return sections[index]
    }
    
    mutating func addSection(type: S, items: [I]) {
        sections.append(.init(type: type, items: items))
    }
}


extension IndexPathSections where S: Equatable, I: Equatable {
    
    func firstIndexPath(of item: I) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() where section.items.contains(item) {
            for (itemIndex, sectionItem) in section.items.enumerated() where sectionItem == item {
                return IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
        return nil
    }
}


extension IndexPathSections {
    
    struct Section<S, I> {
        let type: S
        let items: [I]
    }
}
