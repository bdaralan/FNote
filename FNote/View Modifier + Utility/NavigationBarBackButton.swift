//
//  NavigationBarBackButton.swift
//  FNote
//
//  Created by Dara Beng on 9/27/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct NavigationBarBackButton: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var onTapped: (() -> Void)?
    
    var body: some View {
        Button(action: {
            self.onTapped?()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrow.left")
                .imageScale(.large)
        }
    }
}
