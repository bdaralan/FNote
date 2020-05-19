//
//  Tag+Extension.swift
//  FNote
//
//  Created by Dara Beng on 5/19/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


// MARK: Color

extension Tag {
    
    enum ColorOption: Int64, CaseIterable {
        case red = 0
        case yellow
        case orange
        case green
        case purple
        case blue
        case gray
        
        var color: Color {
            Color(uiColor)
        }
        
        var uiColor: UIColor {
            switch self {
            case .red: return .systemRed
            case .green: return .systemGreen
            case .blue: return .systemBlue
            case .orange: return .systemOrange
            case .yellow: return .systemYellow
            case .purple: return .systemPurple
            case .gray: return .systemGray
            }
        }
    }
}
