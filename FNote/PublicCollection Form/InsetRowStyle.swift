//
//  InsetRowStyle.swift
//  FNote
//
//  Created by Dara Beng on 3/13/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct InsetRowStyle: ViewModifier {
 
    @Environment(\.colorScheme) var colorScheme
    
    var height: CGFloat = 50
    var hPadding: CGFloat = 16
    var alignment: Alignment = .leading
    var background: Color = .noteCardBackground
    var cornerRadius: CGFloat = 10
    
    var borderColor: Color?
    var borderWidth: CGFloat?
    
    var shadowOpacity: Double {
        colorScheme == .light ? 0.17 : 0
    }
    
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, hPadding)
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: alignment)
            .background(background)
            .cornerRadius(cornerRadius)
            .overlay(overlayBorder)
            .shadow(color: Color.primary.opacity(borderColor == nil ? shadowOpacity : 0), radius: 0.5, x: -0.25, y: 0.25)
    }
    
    var overlayBorder: some View {
        guard let borderColor = borderColor else { return AnyView(EmptyView()) }
        return AnyView(RoundedRectangle(cornerRadius: 10).stroke(borderColor, lineWidth: borderWidth ?? 1))
    }
}


