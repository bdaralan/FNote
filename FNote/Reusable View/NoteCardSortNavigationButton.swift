//
//  NoteCardSortNavigationButton.swift
//  FNote
//
//  Created by Dara Beng on 2/1/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardSortNavigationButton: View {
    
    var sortOption: NoteCardSortOption
    
    var ascending: Bool
    
    var action: (() -> Void)?
    
    var size = CGSize(width: 35, height: 44)
    
    
    var body: some View {
        Button(action: action ?? {}) {
            NoteCardSortOptionIcon(option: sortOption, ascending: ascending)
            .frame(width: size.width, height: size.height)
            .contentShape(Rectangle())
        }
        .disabled(action == nil)
    }
}


struct NoteCardSortOptionIcon: View {
    
    var option: NoteCardSortOption
    
    var ascending: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: option.optionImageName).imageScale(.large)
            Image(systemName: ascending ? "arrow.down" : "arrow.up").imageScale(.small)
        }
    }
}
