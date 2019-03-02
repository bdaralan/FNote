//
//  VocabularyViewer.swift
//  FNote
//
//  Created by Dara Beng on 2/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import CoreData


protocol VocabularyViewer: AnyObject {
    
    func viewVocabulary(_ vocabulary: Vocabulary)
}
