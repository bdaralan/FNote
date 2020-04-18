//
//  PresentationAlert.swift
//  FNote
//
//  Created by Dara Beng on 4/17/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct PresentationAlert {
    
    // Must assign before present.
    var content: Alert?
    
    var present = false {
        didSet {
            guard present == false else { return }
            content = nil
        }
    }
}
