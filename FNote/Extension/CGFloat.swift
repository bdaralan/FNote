//
//  CGFloat.swift
//  FNote
//
//  Created by Dara Beng on 1/31/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


extension CGFloat {
    
    static func tableViewHeader(for sizeCategory: ContentSizeCategory) -> CGFloat {
        let large = CGFloat(14)
        switch sizeCategory {
        case .extraSmall: return large - 3
        case .small: return large - 2
        case .medium: return large - 1
        case .large: return large
        case .extraLarge: return large + 1
        case .extraExtraLarge: return large + 2
        case .extraExtraExtraLarge: return large + 3
        case .accessibilityMedium: return large + 4
        case .accessibilityLarge: return large + 5
        case .accessibilityExtraLarge: return large + 6
        case .accessibilityExtraExtraLarge: return large + 7
        case .accessibilityExtraExtraExtraLarge: return large + 8
        @unknown default: return large
        }
    }
}
