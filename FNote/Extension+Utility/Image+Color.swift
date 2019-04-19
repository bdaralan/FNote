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


extension UIColor {
    
    /// A string of six lowercase or uppercase characters without #.
    typealias ColorHex = String
    
    static private let colorHexValue: [Character: Int] = {
        return [
            "0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
            "A": 10, "B": 11, "C": 12, "D": 13, "E": 14, "F": 15
        ]
    }()
    
    convenience init(colorHex: ColorHex) {
        guard colorHex.count == 6 else {
            self.init(white: 1, alpha: 1)
            return
        }
        
        let colorHex = colorHex.uppercased()
        
        let firstRed = UIColor.colorHexValue[colorHex[0]] ?? 0
        let secondRed = UIColor.colorHexValue[colorHex[1]] ?? 0
        let red = CGFloat(firstRed * 16 + secondRed) / 255
        
        let firstGreen = UIColor.colorHexValue[colorHex[2]] ?? 0
        let secondGreen = UIColor.colorHexValue[colorHex[3]] ?? 0
        let green = CGFloat(firstGreen * 16 + secondGreen) / 255
        
        let firstBlue = UIColor.colorHexValue[colorHex[4]] ?? 0
        let secondBlue = UIColor.colorHexValue[colorHex[5]] ?? 0
        let blue = CGFloat(firstBlue * 16 + secondBlue) / 255
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
