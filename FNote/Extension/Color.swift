//
//  Color.swift
//  FNote
//
//  Created by Dara Beng on 10/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


extension Color {
    
    static let appAccent = Color("app-accent-color")
    
    static let noteCardBackground = Color("note-card-background")
    
    static let noteCardDivider = Color("note-card-divider")
    
    static let tagScrollPillBackground = Color("tag-scroll-pill-background")
}


extension UIColor {
    
    static let appAccent = UIColor(named: "app-accent-color")!
    
    static let offWhite = UIColor(white: 0.8, alpha: 1)
    
    static let noteCardBackground = UIColor(named: "note-card-background")
    
    static let noteCardDivider = UIColor(named: "note-card-divider")!
}


extension UIColor {
    
    static private let colorHexValue: [Character: Int] = {
        return [
            "0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
            "A": 10, "B": 11, "C": 12, "D": 13, "E": 14, "F": 15
        ]
    }()
    
    /// A six-character string, 0-9 and A-F. The letters are case insensitive.
    convenience init(hex: String) {
        guard hex.count == 6 else {
            self.init(white: 1, alpha: 1)
            return
        }
        
        let uppercasedHex = hex.uppercased()
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


extension String {
    
    subscript (_ index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}
