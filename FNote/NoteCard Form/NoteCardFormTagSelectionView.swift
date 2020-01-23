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
    
    
    var body: some View {
        List {
            // MARK: Selected Section
            Section(header: Text("SELECTED TAGS").padding(.top, 24)) {
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
        .navigationBarTitle("Tags")
    }
}


struct NoteCardFormTagSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardFormTagSelectionView(formModel: .init(collection: .sample))
    }
}
