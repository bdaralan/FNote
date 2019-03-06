//
//  VocabularyViewer.swift
//  FNote
//
//  Created by Dara Beng on 2/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol VocabularyViewer: AnyObject {
    
    func viewVocabulary(_ vocabulary: Vocabulary)
    
    func selectPoliteness(for viewController: VocabularyViewController, current: Vocabulary.Politeness)
}
