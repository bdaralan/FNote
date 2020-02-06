//
//  NoteCardSortOptionPopoverView.swift
//  FNote
//
//  Created by Dara Beng on 2/5/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardSortOptionPopoverView: View {
    
    var onSelected: ((NoteCardSortOption, Bool) -> Void)?
    
    let options: [(NoteCardSortOption, Bool)] = [
        (.native, true), (.native, false), (.translation, true), (.translation, false)
    ]
    
    
    var body: some View {
        NavigationView {
            Form {
                ForEach(options.indices) { index in
                    Button(action: {
                        self.onSelected?(self.options[index].0, self.options[index].1)
                    }) {
                        NoteCardSortOptionPopoverRow(
                            option: self.options[index].0,
                            ascending: self.options[index].1
                        )
                    }
                }
            }
            .navigationBarTitle("Sort By", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


// MARK: - Row

struct NoteCardSortOptionPopoverRow: View {
    
    var option: NoteCardSortOption
    
    var ascending: Bool
    
    
    var body: some View {
        HStack(spacing: 16) {
            NoteCardSortOptionIcon(option: option, ascending: ascending)
            Text("\(option.title) \(ascending ? "Ascending" : "Descending")")
        }
    }
}


struct NoteCardSortOptionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(alignment: .center) {
            Color.black.opacity(0.15).edgesIgnoringSafeArea(.all)
            NoteCardSortOptionPopoverView()
                .accentColor(.appAccent)
        }
    }
}



