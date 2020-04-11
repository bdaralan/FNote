//
//  WelcomeGuideView.swift
//  FNote
//
//  Created by Dara Beng on 11/23/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct WelcomeGuideView: View {
    
    var iCloudActive: Bool
    
    var action: (() -> Void)?
    
    var imageName: String {
        iCloudActive ? "rectangle.stack.fill.badge.plus" : "exclamationmark.icloud.fill"
    }
    
    var firstString: String {
        iCloudActive ? "No collection selected." : "Cannot Access iCloud"
    }
    
    var secondString: String {
        if iCloudActive {
            return "Select or Create a new collection"
        } else {
            return "Please make sure FNote is turned on\nin iCloud Settings."
        }
    }
    
    
    var body: some View {
        VStack(spacing: iCloudActive ? 16 : 0) {
            Button(action: action ?? {}) {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(iCloudActive ? .appAccent : .primary)
            }
            .disabled(!iCloudActive)
            
            VStack(spacing: 8) {
                Text(firstString)
                    .fontWeight(iCloudActive ? .regular : .bold)
                Text(secondString)
            }
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
    }
}


struct CreateNoteCardCollectionGuideView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeGuideView(iCloudActive: false, action: nil)
    }
}
