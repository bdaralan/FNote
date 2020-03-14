//
//  ScrollViewSection.swift
//  FNote
//
//  Created by Dara Beng on 3/13/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct ScrollViewSection<Content>: View where Content: View {
    
    @Environment(\.sizeCategory) var sizeCategory
    
    let header: String
    
    let footer: String
    
    let content: Content
    
    
    init(header: String = "", footer: String = "", @ViewBuilder content: () -> Content) {
        self.header = header
        self.footer = footer
        self.content = content()
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !header.isEmpty {
                Text(header)
                    .font(.system(size: .tableViewHeader(for: sizeCategory)))
                    .foregroundColor(.secondary)
            }
            
            content
                .frame(maxWidth: .infinity)
            
            if !footer.isEmpty {
                Text(footer)
                    .font(.system(size: .tableViewHeader(for: sizeCategory)))
                    .foregroundColor(.secondary)
            }
        }
    }
}


struct ScrollViewSection_Previews: PreviewProvider {
    static var previews: some View {
        ScrollViewSection(header: "HEADER", footer: "This is some footer text.") {
            Color.pink.frame(height: 150)
        }
        .padding(.horizontal,16)
    }
}
