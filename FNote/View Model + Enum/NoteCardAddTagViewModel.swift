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
    
    mutating func configure(for noteCard: NoteCard, allTags: [Tag]) {
        includedTags = noteCard.tags.compactMap({ TagViewModel(tag: $0) })
        excludedTags = allTags.compactMap { tag -> TagViewModel? in
            let tagModel = TagViewModel(tag: tag)
            guard !includedTags.contains(where: { $0.uuid == tagModel.uuid }) else { return nil }
            return tagModel
        }
        includedTags.sortByName()
        excludedTags.sortByName()
    }
    
    mutating func updateTag(with tag: TagViewModel) {
        if let index = includedTags.firstIndex(where: { $0.uuid == tag.uuid }) {
            includedTags[index] = tag
            includedTags.sortByName()
            onTagUpdated?(tag)
            return
        
        }
        
        if let index = excludedTags.firstIndex(where: { $0.uuid == tag.uuid }) {
            excludedTags[index] = tag
            excludedTags.sortByName()
            onTagUpdated?(tag)
            return
        }
    }
    
    mutating func addToIncludedTags(_ tag: TagViewModel) {
        if let index = excludedTags.firstIndex(where: { $0.uuid == tag.uuid }) {
            excludedTags.remove(at: index)
            includedTags.append(tag)
            includedTags.sortByName()
            onTagIncluded?(tag)
            return
        }
        
        if !isIncludedTag(tag) {
            includedTags.append(tag)
            includedTags.sortByName()
            onTagCreated?(tag)
            return
        }
    }
    
    mutating func addToExcludedTags(_ tag: TagViewModel) {
        guard let index = includedTags.firstIndex(where: { $0.uuid == tag.uuid }) else { return }
        includedTags.remove(at: index)
        excludedTags.append(tag)
        excludedTags.sortByName()
        onTagExcluded?(tag)
    }
}
