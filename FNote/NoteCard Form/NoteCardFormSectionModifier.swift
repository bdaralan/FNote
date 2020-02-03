//
//  NoteCardFormSectionModifier.swift
//  FNote
//
//  Created by Dara Beng on 2/2/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardFormSectionModifier: ViewModifier {
    
    @Environment(\.sizeCategory) var sizeCategory
    
    var header: String
    
    var footer = ""
    
    var hPadding: CGFloat = 20
    
    
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
