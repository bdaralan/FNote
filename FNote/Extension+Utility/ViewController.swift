//
//  ViewController.swift
//  FNote
//
//  Created by Dara Beng on 3/1/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


extension UIViewController {
    
    /// Create a navigation controller and set the view controller as its root view controller.
    func embedNavigationController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
    
    static func defaultPreferredContentSize() -> CGSize {
        return .init(width: 540, height: 620)
    }
    
    static func preferredContentSizeWidth() -> CGFloat {
        let preferredWidth = defaultPreferredContentSize().width
        let screenSize = UIScreen.main.bounds.size
        guard preferredWidth >= screenSize.width else { return preferredWidth }
        return min(screenSize.width, screenSize.height) / 2
    }
}
