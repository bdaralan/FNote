//
//  OverlayView.swift
//  FNote
//
//  Created by Dara Beng on 3/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct OverlayView<Content>: View where Content: View {
        
    @Binding var isPresented: Bool
    
    let content: Content
    
    let alignment: Alignment
    
    var onTouchedOutside: () -> Void
    
    
    init(isPresented: Binding<Bool>, alignment: Alignment = .center, onOutsideTapped: @escaping () -> Void = {}, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
        self.alignment = alignment
        self.onTouchedOutside = onOutsideTapped
    }
    
    
    var body: some View {
        ZStack(alignment: alignment) {
            if isPresented {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.2)
                    .transition(.opacity)
                    .animation(Animation.easeInOut(duration: 0.4))
                    .onTapGesture(perform: onTouchedOutside)
                
                content
                    .transition(.move(edge: .bottom))
                    .animation(.spring())
            }
        }
        .animation(.default)
    }
}


struct InputOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OverlayView(isPresented: .constant(true)) {
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 250)
                    .cornerRadius(15)
                    .padding(.horizontal)
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .colorScheme(.light)
            
            OverlayView(isPresented: .constant(true)) {
                Rectangle()
                .fill(Color.black)
                .frame(height: 250)
                .cornerRadius(15)
                .padding(.horizontal)
            }
            .background(Color(.tertiarySystemBackground).edgesIgnoringSafeArea(.all))
            .colorScheme(.dark)
        }
    }
}
