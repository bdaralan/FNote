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
    static var connection: UIImage { return UIImage(named: "connection")! }
    static var politeness: UIImage { return UIImage(named: "politeness")! }
    static var favorite: UIImage { return UIImage(named: "favorite")! }
    static var tag: UIImage { return UIImage(named: "tag")! }
    static var trashCan: UIImage { return UIImage(named: "trash-can")! }
    static var more: UIImage { return UIImage(named: "more")! }
    
    // MARK: - Nav Item
    static var profileNavImagePlaceholder: UIImage { return UIImage(named: "nav-profile-img-placeholder")! }
    
    
    // MARK: - Tab Bar Item
    static var tabBarVocabCollection: UIImage { return UIImage(named: "vocabulary-collection")! }
    
    // MARK: - Image
    static var lightbulb: UIImage { return UIImage(named: "lightbulb")! }
    static var userProfilePlaceholder: UIImage { return UIImage(named: "user-profile-placeholder")! }
}


extension UIColor {
    
    static let offWhiteBackground = UIColor(named: "off-white-background")
    static let uiControlTint = UISegmentedControl().tintColor
    
    static let vocabularyFavoriteStarTrue = UIColor(named: "favorite-vocab-true")
    static let vocabularyFavoriteStarFalse = UIColor(named: "favorite-vocab-false")
}
