//
//  UIView.swift
//  FNote
//
//  Created by Dara Beng on 1/17/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


extension UIView {
    
    func addSubviews(_ views: UIView..., useAutoLayout: Bool) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = !useAutoLayout
            addSubview(view)
        }
    }
}


extension UIStackView {
    
    func addArrangedSubviews(_ views: UIView...) {
        for view in views {
            addArrangedSubview(view)
        }
    }
}


extension NSLayoutConstraint {
    
    static func activateConstraints(_ constraints: NSLayoutConstraint...) {
        NSLayoutConstraint.activate(constraints)
    }
}


extension UILabel {
    
    convenience init(text: String) {
        self.init()
        self.text = text
    }
}
