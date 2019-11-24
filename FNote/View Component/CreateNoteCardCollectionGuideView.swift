//
//  CreateNoteCardCollectionGuideView.swift
//  FNote
//
//  Created by Dara Beng on 11/23/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct CreateNoteCardCollectionGuideView: View {
    
    var action: (() -> Void)?
    
    
    var body: some View {
        VStack(spacing: 24) {
            Button(action: action ?? {}) {
                Image(systemName: "rectangle.stack.fill.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(Color(UIColor.quaternaryLabel))
            }
            .buttonStyle(PlainButtonStyle())
            VStack(spacing: 8) {
                Text("No collection selected")
                Text("Select or create a new collection")
            }
            .foregroundColor(Color(UIColor.tertiaryLabel))
        }
    }
}


struct CreateNoteCardCollectionGuideView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNoteCardCollectionGuideView()
    }
}
