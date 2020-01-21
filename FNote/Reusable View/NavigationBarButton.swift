//
//  NavigationBarButton.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct NavigationBarButton: View {
    
    var imageName: String
    
    var action: (() -> Void)?
    
    var size = CGSize(width: 35, height: 44)
    
    
    var body: some View {
        Button(action: action ?? {}) {
            Image(systemName: imageName)
                .imageScale(.large)
                .frame(width: size.width, height: size.height)
                .contentShape(Rectangle())
        }
        .disabled(action == nil)
    }
}


struct NavigationBarButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Color.orange
                .navigationBarItems(
                    trailing: NavigationBarButton(imageName: "plus", action: nil)
            )
        }
    }
}
