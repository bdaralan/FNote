//
//  NavigationItemButtonStyle.swift
//  FNote
//
//  Created by Dara Beng on 11/28/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


/// A button style for navigation item that have a fixed size of invisible tap area.
/// Intended to be used with image button.
struct NavigationItemIconStyle: ButtonStyle {
    
    @Environment(\.layoutDirection) var layoutDirection
    
    var size = CGSize(width: 30, height: 35)
    
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: layoutDirection == .leftToRight ? .trailing : .leading) {
            Rectangle()
                .fill(Color.clear)
            configuration.label
                .foregroundColor(.appAccent)
        }
        .frame(width: size.width, height: size.height, alignment: .center)
        .opacity(configuration.isPressed ? 0.3 : 1)
    }
}
