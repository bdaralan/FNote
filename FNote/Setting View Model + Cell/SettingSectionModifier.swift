//
//  SettingSectionModifier.swift
//  FNote
//
//  Created by Dara Beng on 1/31/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct SettingSectionModifier: ViewModifier {
    
    @Environment(\.sizeCategory) var sizeCategory
    
    var header: String
    
    var footer = ""
    
    var hPadding: CGFloat = 0
    
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !header.isEmpty {
                Text(header)
                    .font(.system(size: .tableViewHeader(for: sizeCategory)))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, hPadding)
            }
            
            content
            
            if !footer.isEmpty {
                Text(footer)
                    .font(.system(size: .tableViewHeader(for: sizeCategory)))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, hPadding)
            }
        }
    }
}
