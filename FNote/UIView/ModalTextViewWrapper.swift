//
//  ModalTextViewWrapper.swift
//  FNote
//
//  Created by Dara Beng on 9/15/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct ModalTextViewWrapper: UIViewRepresentable {
    
    @Binding var text: String
    
    @Binding var isActive: Bool
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = .preferredFont(forTextStyle: .body)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        context.coordinator.handleFirstResponse(for: uiView, isActive: isActive)
    }
    
    
    // MARK - Coordinator
    
    class Coordinator: NSObject, UITextViewDelegate, FirstTimeResponder {
        
        @Binding var text: String
        
        var isActive = false
        
        var shouldResponse = false
        
        init(text: Binding<String>) {
            _text = text
        }
    }
}
