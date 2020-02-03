//
//  TextFieldWrapper.swift
//  FNote
//
//  Created by Dara Beng on 9/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct TextFieldWrapper: UIViewRepresentable {
    
    @Binding var isActive: Bool
    
    @Binding var text: String
    
    var placeholder: String
    
    var nextResponder: UIResponder?
    
    var onCommit: (() -> Void)?
    
    var onNextResponder: ((UIResponder) -> Void)?
    
    var configure: ((UITextField) -> Void)?
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(wrapper: self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        context.coordinator.textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.update(with: self)
    }
    
    
    // MARK: Coordinator
    
    class Coordinator: NSObject, UITextFieldDelegate, InputViewResponder {
        
        var wrapper: TextFieldWrapper
        
        let textField = UITextField()

        
        init(wrapper: TextFieldWrapper) {
            self.wrapper = wrapper
            super.init()
            setupTextField()
            wrapper.configure?(textField)
        }
    
        
        func update(with wrapper: TextFieldWrapper) {
            self.wrapper = wrapper
            textField.text = wrapper.text
            textField.placeholder = wrapper.placeholder
            handleFirstResponder(for: textField, isFirstResponder: wrapper.isActive)
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if let nextResponder = wrapper.nextResponder {
                nextResponder.becomeFirstResponder()
                return false
            } else {
                wrapper.onCommit?()
                textField.resignFirstResponder()
                return true
            }
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            wrapper.isActive = true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            wrapper.isActive = false
        }
        
        func setupTextField() {
            textField.font = .preferredFont(forTextStyle: .largeTitle)
            textField.returnKeyType = .done
            textField.clearButtonMode = .whileEditing
            textField.delegate = self
            textField.addTarget(self, action: #selector(handleEditingChanged), for: .editingChanged)
            textField.adjustsFontForContentSizeCategory = true
            textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        
        @objc private func handleEditingChanged(_ sender: UITextField) {
            wrapper.text = sender.text!
        }
    }
}
