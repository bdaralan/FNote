//
//  ModalTextViewWrapper.swift
//  FNote
//
//  Created by Dara Beng on 9/15/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI
import Down


struct ModalTextViewWrapper: UIViewRepresentable {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var text: String
    
    @Binding var isFirstResponder: Bool
    
    var disableEditing = false
    
    var renderMarkdown = false
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(wrapper: self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        context.coordinator.textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.update(with: self)
    }
    
    
    // MARK - Coordinator
    
    class Coordinator: NSObject, UITextViewDelegate, InputViewResponder {

        var wrapper: ModalTextViewWrapper
        
        let textView = UITextView()
        
        
        init(wrapper: ModalTextViewWrapper) {
            self.wrapper = wrapper
            super.init()
            setupTextView()
            listenToKeyboardNotification()
        }
        
        
        func update(with wrapper: ModalTextViewWrapper) {
            let sameText = textView.text == wrapper.text
            let sameColorScheme = self.wrapper.colorScheme == wrapper.colorScheme
            let shouldUpdateText = !sameText || !sameColorScheme
            
            self.wrapper = wrapper
            
            textView.isEditable = !wrapper.disableEditing
            
            if !wrapper.disableEditing {
                handleFirstResponder(for: textView, isFirstResponder: wrapper.isFirstResponder)
            }
            
            guard shouldUpdateText else { return }
            let renderMarkdown = wrapper.renderMarkdown
            let colorScheme = wrapper.colorScheme
            
            if renderMarkdown, let markdown = createMarkdown(from: wrapper.text, colorScheme: colorScheme) {
                textView.attributedText = markdown
            } else {
                textView.text = wrapper.text
            }
        }
        
        func createMarkdown(from string: String, colorScheme: ColorScheme) -> NSAttributedString? {
            var config = DownStylerConfiguration()
            
            switch colorScheme {
            case .dark:
                config.colors = DarkColorCollection()
            case .light:
                config.colors = LightColorCollection()
            @unknown default:
                config.colors = LightColorCollection()
            }
            
            let styler = DownStyler(configuration: config)
            let down = Down(markdownString: string)
            return try? down.toAttributedString(.default, styler: styler)
        }
        
        func setupTextView() {
            textView.delegate = self
            textView.font = .preferredFont(forTextStyle: .body)
            textView.dataDetectorTypes = .all
        }
        
        func textViewDidChange(_ textView: UITextView) {
            wrapper.text = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            wrapper.isFirstResponder = true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            wrapper.isFirstResponder = false
        }
        
        func listenToKeyboardNotification() {
            let center = NotificationCenter.default
            let keyboardFrameDidChange = UIResponder.keyboardDidChangeFrameNotification
            let keyboardDidHide = UIResponder.keyboardDidHideNotification
            center.addObserver(self, selector: #selector(handleKeyboardFrameChanged), name: keyboardFrameDidChange, object: nil)
            center.addObserver(self, selector: #selector(handleKeyboardDismissed), name: keyboardDidHide, object: nil)
        }
        
        @objc private func handleKeyboardFrameChanged(_ notification: Notification) {
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


// MARK: - Markdown Color

struct DarkColorCollection: ColorCollection {
    
    static let offWhiteColor = UIColor(white: 0.8, alpha: 1)
    
    var heading1: DownColor = offWhiteColor
    var heading2: DownColor = offWhiteColor
    var heading3: DownColor = offWhiteColor
    var body: DownColor = offWhiteColor
    var code: DownColor = offWhiteColor
    var link: DownColor = .appAccent
    var quote: DownColor = offWhiteColor
    var quoteStripe: DownColor = offWhiteColor
    var thematicBreak: DownColor = offWhiteColor
    var listItemPrefix: DownColor = offWhiteColor
    var codeBlockBackground: DownColor = .lightGray
}


struct LightColorCollection: ColorCollection {
    
    var heading1: DownColor = .black
    var heading2: DownColor = .black
    var heading3: DownColor = .black
    var body: DownColor = .black
    var code: DownColor = .black
    var link: DownColor = .appAccent
    var quote: DownColor = .black
    var quoteStripe: DownColor = .black
    var thematicBreak: DownColor = .black
    var listItemPrefix: DownColor = .black
    var codeBlockBackground: DownColor = .lightGray
}
