//
//  String.swift
//  FNote
//
//  Created by Dara Beng on 3/15/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


extension String {
    
    init(count: Int, single: String, plural: String, separator: String = " ") {
        let suffix = count > 1 ? plural : single
        self.init("\(count)\(separator)\(suffix)")
    }
}


extension String {
    
    subscript (_ index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}
