//
//  Image.swift
//  FNote
//
//  Created by Dara Beng on 1/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


extension UIImage {
    
    // MARK: - Button
    static var alternative: UIImage { return UIImage(named: "alternative")! }
    static var relation: UIImage { return UIImage(named: "relation")! }
    static var favorite: UIImage { return UIImage(named: "favorite")! }
    static var politeness: UIImage { return UIImage(named: "politeness")! }
    static var trashCan: UIImage { return UIImage(named: "trash-can")! }
    
    // MARK: - Nav Item
    static var profileNavImagePlaceholder: UIImage { return UIImage(named: "nav-profile-img-placeholder")! }
    
    
    // MARK: - Tab Bar Item
    static var tabBarVocabCollection: UIImage { return UIImage(named: "vocabulary-collection")! }
    
    // MARK: - Image
    static var lightbulb: UIImage { return UIImage(named: "lightbulb")! }
}


extension UIColor {
    
    static let offWhiteBackground = UIColor(named: "off-white-background")
}
