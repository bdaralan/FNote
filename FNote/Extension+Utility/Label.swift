//
//  Label.swift
//  FNote
//
//  Created by Dara Beng on 3/22/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


extension UILabel {
    
    func estimatedWidth(for string: String) -> CGFloat {
        text = string
        sizeToFit()
        return bounds.width
    }
}
