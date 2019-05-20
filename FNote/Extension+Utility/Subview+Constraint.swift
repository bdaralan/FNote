//
//  Subview+Constraint.swift
//  SharX
//
//  Created by Dara Beng on 1/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


extension UIView {
    
    #warning("REMOVE THIS")
    func addSubviews(_ subviews: [UIView]) {
        for view in subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }
    
    func addSubviews(_ subviews: UIView...) {
        for view in subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }
}


extension NSLayoutConstraint {
    
    static func activate(_ constraints: NSLayoutConstraint...) {
        NSLayoutConstraint.activate(constraints)
    }
}
