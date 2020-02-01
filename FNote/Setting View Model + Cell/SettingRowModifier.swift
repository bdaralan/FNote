//
//  SettingRowModifier.swift
//  FNote
//
//  Created by Dara Beng on 1/31/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct SettingRowModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .frame(height: 50)
            .background(Color.noteCardBackground)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}
