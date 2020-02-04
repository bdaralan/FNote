//
//  NoteCardFormRowModifier.swift
//  FNote
//
//  Created by Dara Beng on 2/2/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardFormRowModifier: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    var shadowOpacity: Double {
        colorScheme == .light ? 0.17 : 0
    }
    
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .frame(height: 50)
            .background(Color.noteCardBackground)
            .cornerRadius(10)
            .shadow(color: Color.primary.opacity(shadowOpacity), radius: 0.5, x: -0.25, y: 0.25)
    }
}
