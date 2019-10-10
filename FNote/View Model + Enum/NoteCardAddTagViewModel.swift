//
//  NoteCardAddTagViewModel.swift
//  FNote
//
//  Created by Dara Beng on 10/2/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


struct NoteCardAddTagViewModel {
    
    // MARK: Property
    
    private(set) var includedTags = [TagViewModel]()
    
    private(set) var excludedTags = [TagViewModel]()
    
    
    // MARK: Action
    
    var onTagIncluded: ((TagViewModel) -> Void)?
    
    var onTagExcluded: ((TagViewModel) -> Void)?
    
    var onTagUpdated: ((TagViewModel) -> Void)?
    
    var onTagCreated: ((TagViewModel) -> Void)?
    
    
    // MARK: Check Method
    
    func isIncludedTag(_ tag: TagViewModel) -> Bool {
        includedTags.contains(where: { $0.uuid == tag.uuid })
    }
    
    func isExcludedTag(_ tag: TagViewModel) -> Bool {
        excludedTags.contains(where: { $0.uuid == tag.uuid })
    }
    
    
    // MARK: Method
    
    mutating func setTags(included: [TagViewModel], excluded: [TagViewModel]) {
        includedTags = included
        excludedTags = excluded
    }
    
    mutating func updateTag(with tag: TagViewModel, sort: Bool) {
        var isUpdated = false
        if let index = includedTags.firstIndex(where: { $0.uuid == tag.uuid }) {
            includedTags[index] = tag
            isUpdated = true
            if sort {
                includedTags.sortByName()
            }
        
        } else if let index = excludedTags.firstIndex(where: { $0.uuid == tag.uuid }) {
            excludedTags[index] = tag
            isUpdated = true
            if sort {
                excludedTags.sortByName()
            }
        }
        
        if isUpdated {
            onTagUpdated?(tag)
        }
    }
    
    mutating func addToIncludedTags(_ tag: TagViewModel, sort: Bool) {
        if let index = excludedTags.firstIndex(where: { $0.uuid == tag.uuid }) {
            excludedTags.remove(at: index)
            includedTags.append(tag)
            onTagIncluded?(tag)
        } else {
            if !isIncludedTag(tag) {
                includedTags.append(tag)
                onTagCreated?(tag)
            }
        }
        
        if sort {
            includedTags.sortByName()
        }
    }
    
    mutating func addToExcludedTags(_ tag: TagViewModel, sort: Bool) {
        guard let index = includedTags.firstIndex(where: { $0.uuid == tag.uuid }) else { return }
        includedTags.remove(at: index)
        excludedTags.append(tag)
        if sort {
            excludedTags.sortByName()
        }
        onTagExcluded?(tag)
    }
}
