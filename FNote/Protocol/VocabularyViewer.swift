//
//  VocabularyViewer.swift
//  FNote
//
//  Created by Dara Beng on 2/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit
import CoreData


/// A protocol with a set of methods to create, update, and delete vocabluary.
protocol VocabularyViewer: AnyObject {
    
    func addNewVocabulary(to collection: VocabularyCollection)
    
    func viewVocabulary(_ vocabulary: Vocabulary)
    
    func removeVocabulary(_ vocabulary: Vocabulary, from collection: VocabularyCollection, sender: UIView)
    
    func selectPoliteness(for vocabularyVC: VocabularyViewController, current: Vocabulary.Politeness)
    
    func selectTags(for vocabularyVC: VocabularyViewController, current: [String], existingTags: [String])
    
    func selectVocabularyConnection(for vocabularyVC: VocabularyViewController)
}
