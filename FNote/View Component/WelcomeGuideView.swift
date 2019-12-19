//
//  WelcomeGuideView.swift
//  FNote
//
//  Created by Dara Beng on 11/23/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct WelcomeGuideView: View {
    
    var isInvalidUser = false
    
    var action: (() -> Void)?
    
    var imageName: String {
        isInvalidUser ? "person.crop.circle.fill.badge.exclam" : "rectangle.stack.fill.badge.plus"
    }
    
    var imageColor: Color {
        isInvalidUser ? .primary : .init(UIColor.tertiaryLabel)
    }
    
    var firstString: String {
        isInvalidUser ? "No iCloud Detected" : "No collection selected"
    }
    
    var secondString: String {
        let invalidUserMessage = """
        Please make sure your Apple ID is logged in
        and FNote is turned on in iCloud Settings.
        """
        return isInvalidUser ? invalidUserMessage : "Select or create a new collection"
    }
    
    
    var body: some View {
        VStack(spacing: 24) {
            Button(action: action ?? {}) {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(imageColor)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isInvalidUser)
            
            VStack(spacing: 8) {
                Text(firstString)
                Text(secondString)
            }
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
    }
}


struct CreateNoteCardCollectionGuideView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeGuideView()
    }
}