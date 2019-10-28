//
//  NoteCardNavigationButtonStyle.swift
//  FNote
//
//  Created by Dara Beng on 10/28/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardNavigationButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(1)
    }
}
