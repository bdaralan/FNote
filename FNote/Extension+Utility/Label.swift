//
//  Label.swift
//  FNote
//
//  Created by Dara Beng on 3/22/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


extension UILabel {
    
    static func estimatedWidth(for string: String) -> CGFloat {
        let label = UILabel()
        label.text = string
        label.sizeToFit()
        return label.bounds.width
    }
}
