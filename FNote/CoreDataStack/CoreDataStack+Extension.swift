//
//  CoreDataStack+Sample.swift
//  FNote
//
//  Created by Dara Beng on 9/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


// MARK: - Sample Data

extension CoreDataStack {
    
    static let sampleContext = CoreDataStack.current.mainContext.newChildContext()
}

