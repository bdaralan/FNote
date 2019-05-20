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
    static let vocabularyAttributeTint = UIColor.darkGray
    
    static let vocabularyFavoriteStarTrue = UIColor(colorHex: "FF1452")
    static let vocabularyFavoriteStarFalse = vocabularyAttributeTint
}


extension UIColor {
    
    /// A six-character string, 0-9 and A-F. The letters are case insensitive.
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
        
        let uppercasedHex = colorHex.uppercased()
        let r1Hex = uppercasedHex[0]
        let r2Hex = uppercasedHex[1]
        let g1Hex = uppercasedHex[2]
        let g2Hex = uppercasedHex[3]
        let b1Hex = uppercasedHex[4]
        let b2Hex = uppercasedHex[5]
        let values = UIColor.colorHexValue
        
        guard let red1 = values[r1Hex], let red2 = values[r2Hex],
            let green1 = values[g1Hex], let green2 = values[g2Hex],
            let blue1 = values[b1Hex], let blue2 = values[b2Hex] else {
            self.init(white: 1, alpha: 1)
            return
        }
        
        let red = CGFloat(red1 * 16 + red2) / 255
        let green = CGFloat(green1 * 16 + green2) / 255
        let blue = CGFloat(blue1 * 16 + blue2) / 255
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
