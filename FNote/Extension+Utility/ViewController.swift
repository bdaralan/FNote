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
    func withNavController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
}
