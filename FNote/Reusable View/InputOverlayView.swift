//
//  InputOverlayView.swift
//  FNote
//
//  Created by Dara Beng on 3/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct InputOverlayView<Content>: View where Content: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var isPresented: Bool
    
    var onTouchOutside: () -> Void
        
    let content: Content
    
    var overlayColor: Color {
        colorScheme == .light ? .black : .white
    }
    
    
    init(isPresented: Binding<Bool>, onTouchOutside: @escaping () -> Void = {}, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.onTouchOutside = onTouchOutside
        self.content = content()
    }
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                overlayColor
                    .opacity(0.2)
                    .transition(.opacity)
                    .animation(Animation.easeInOut(duration: 0.4))
                    .onTapGesture(perform: onTouchOutside)
            }
            
            if isPresented {
                content
                    .frame(maxWidth: .infinity)
                    .background(Color.noteCardBackground)
                    .cornerRadius(15)
                    .shadow(color: Color.primary.opacity(0.2), radius: 1, x: 0, y: 0)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom))
                    .animation(.spring())
            }
        }
        .animation(.default)
        .edgesIgnoringSafeArea(.all)
    }
}


struct InputOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        InputOverlayView(isPresented: .constant(true)) {
            Color.orange.frame(height: 250)
        }
    }
}
