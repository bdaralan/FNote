//
//  NoteCardFormTagSelectionView.swift
//  FNote
//
//  Created by Dara Beng on 1/22/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardFormTagSelectionView: View {
    
    @ObservedObject var formModel: NoteCardFormModel
    
    var showSelectedHeader = true
    var showUnselectedSection = true
    
    var selectedHeader: String {
        showSelectedHeader ? "SELECTED TAGS" : ""
    }
    
    var selectedHeaderPadding: CGFloat {
        showSelectedHeader ? 24 : 0
    }
    
    
    var body: some View {
        List {
            // MARK: Selected Section
            Section(header: Text(selectedHeader).padding(.top, selectedHeaderPadding)) {
                ForEach(formModel.selectedTags.sortedByName()) { tag in
                    Button(action: { self.formModel.onTagSelected?(tag) }) {
                        Text(tag.name)
                            .foregroundColor(.primary)
                    }
                }
                
                if formModel.selectedTags.isEmpty {
                    Text("None")
                        .foregroundColor(.secondary)
                }
            }
            
            if showUnselectedSection {
                // MARK: Unselected Section
                Section(header: Text("UNSELECTED TAGS")) {
                    ForEach(formModel.selectableTags.sortedByName()) { tag in
                        if !self.formModel.selectedTags.contains(tag) {
                            Button(action: { self.formModel.onTagSelected?(tag) }) {
                                Text(tag.name)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    if formModel.selectedTags.isSuperset(of: formModel.selectableTags) {
                        Text("None")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationBarTitle("Tags")
        .listStyle(GroupedListStyle())
    }
}


struct NoteCardFormTagSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardFormTagSelectionView(formModel: .init(collection: .sample))
    }
}
