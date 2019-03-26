//
//  Font.swift
//  FNote
//
//  Created by Dara Beng on 3/26/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


extension UIFont {
    
    /// Update font with the given symbolic traits.
    /// - returns: The updated font or the same font if the traits does not have any effects.
    func withSymbolicTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        var updatedTraits = fontDescriptor.symbolicTraits
        updatedTraits.insert(traits)
        guard let updateFontDescriptor = fontDescriptor.withSymbolicTraits(updatedTraits) else { return self }
        let font = UIFont(descriptor: updateFontDescriptor, size: 0)
        return font
    }
}
