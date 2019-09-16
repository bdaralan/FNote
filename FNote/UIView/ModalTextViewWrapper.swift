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
        context.coordinator.textView = textView
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        context.coordinator.handleFirstResponse(for: uiView, isActive: isActive)
    }
    
    
    // MARK - Coordinator
    
    class Coordinator: NSObject, UITextViewDelegate, FirstTimeResponder {
        
        var textView: UITextView! {
            didSet { setupTextView() }
        }
        
        @Binding var text: String
        
        var isActive = false
        
        var shouldResponse = false
        
        init(text: Binding<String>) {
            _text = text
            super.init()
        }
        
        
        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
        }
        
        func setupTextView() {
            textView.delegate = self
            listenToKeyboardNotitication()
        }
        
        func listenToKeyboardNotitication() {
            let center = NotificationCenter.default
            let keybordFrameDidChange = UIResponder.keyboardDidChangeFrameNotification
            let keyboardDidHide = UIResponder.keyboardDidHideNotification
            center.addObserver(self, selector: #selector(handleKeyboardFrameChanged), name: keybordFrameDidChange, object: nil)
            center.addObserver(self, selector: #selector(handleKeyboardDismissed), name: keyboardDidHide, object: nil)
        }
        
        @objc private func handleKeyboardFrameChanged(_ notification: Notification) {
            print(notification.userInfo!)
            guard let userInfo = notification.userInfo else { return }
            guard let keyboardFrame = userInfo["UIKeyboardFrameEndUserInfoKey"] as? CGRect else { return }
            textView.contentInset.bottom = keyboardFrame.height
            textView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height
        }
        
        @objc private func handleKeyboardDismissed(_ notification: Notification) {
            UIView.animate(withDuration: 0.4) { [weak self] in
                guard let self = self else { return }
                self.textView.contentInset.bottom = 0
                self.textView.verticalScrollIndicatorInsets.bottom = 0
            }
        }
    }
}
