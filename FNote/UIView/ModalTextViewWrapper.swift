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
                config.colors = DarkSchemeColorCollection()
            case .light:
                config.colors = LightSchemeColorCollection()
            @unknown default:
                config.colors = LightSchemeColorCollection()
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

struct DarkSchemeColorCollection: ColorCollection {
    var heading1: DownColor = .offWhite
    var heading2: DownColor = .offWhite
    var heading3: DownColor = .offWhite
    var body: DownColor = .offWhite
    var code: DownColor = .offWhite
    var link: DownColor = .appAccent
    var quote: DownColor = .offWhite
    var quoteStripe: DownColor = .offWhite
    var thematicBreak: DownColor = .offWhite
    var listItemPrefix: DownColor = .offWhite
    var codeBlockBackground: DownColor = .lightGray
}


struct LightSchemeColorCollection: ColorCollection {
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
