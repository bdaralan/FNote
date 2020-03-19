//
//  CommunityActionButton.swift
//  FNote
//
//  Created by Dara Beng on 3/19/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct CommunityActionButton: View {
    
    var action: () -> Void
    
    var systemImage: String?
    
    var offsetY: CGFloat = 0
    
    var title: String
    
    var description: String?
    
    
    var body: some View {
        Button(action: action) {
            HStack {
                systemImage.map { name in
                    Image(systemName: name)
                    .font(Font.body.weight(.black))
                    .foregroundColor(.primary)
                    .offset(y: offsetY)
                }
                
                VStack(spacing: 4) {
                    Text(title)
                        .foregroundColor(.primary)
                        .fontWeight(.black)
                        .fixedSize()
                    
                    description.map { description in
                        Text(description)
                            .foregroundColor(.secondary)
                            .font(.footnote)
                            .fixedSize()
                    }
                }
            }
                .modifier(InsetRowStyle(height: 65))
        }
    }
}

struct CommunityActionButton_Previews: PreviewProvider {
    static var previews: some View {
        CommunityActionButton(action: {}, title: "Title", description: "description")
    }
}
