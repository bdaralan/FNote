//
//  WelcomeGuideView.swift
//  FNote
//
//  Created by Dara Beng on 11/23/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct WelcomeGuideView: View {
    
    var iCloudActive = false
    
    var action: (() -> Void)?
    
    var imageName: String {
        iCloudActive ? "rectangle.stack.fill.badge.plus" : "person.crop.circle.fill.badge.exclam"
    }
    
    var imageColor: Color {
        iCloudActive ? .init(UIColor.tertiaryLabel) : .primary
    }
    
    var firstString: String {
        iCloudActive ? "No collection selected" : "No iCloud Detected"
    }
    
    var secondString: String {
        if iCloudActive {
            return "Select or create a new collection"
        } else {
            return """
            Please make sure your Apple ID is logged in
            and FNote is turned on in iCloud Settings.
            """
        }
    }
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Button(action: action ?? {}) {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(imageColor)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!iCloudActive)
                
                VStack(spacing: 8) {
                    Text(firstString)
                    Text(secondString)
                }
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }
            .navigationBarTitle("FNote")
        }
    }
}


struct CreateNoteCardCollectionGuideView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeGuideView()
    }
}
