//
//  TextFieldWrapper.swift
//  FNote
//
//  Created by Dara Beng on 11/25/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct TextFieldWrapper: UIViewRepresentable {
    
    @Binding var text: String
    
    @Binding var isFirstResponder: Bool
    
    var placeholder: String
    
    var onEditingChanged: ((Bool) -> Void)?
    
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
        
        var responderOnFirstLoad = true
        
        
        init(wrapper: TextFieldWrapper) {
            self.wrapper = wrapper
            super.init()
            wrapper.configure?(textField)
            textField.delegate = self
        }
        
        
        func update(with wrapper: TextFieldWrapper) {
            self.wrapper = wrapper
            handleFirstResponder(for: textField, isFirstResponder: wrapper.isFirstResponder || responderOnFirstLoad)
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            wrapper.isFirstResponder = true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            wrapper.isFirstResponder = false
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            wrapper.isFirstResponder = false
        }
        
        @objc private func handleTextFieldTextChanged() {
            wrapper.text = textField.text ?? ""
        }
        
        private func setupTextFieldTarget() {
            textField.addTarget(self, action: #selector(handleTextFieldTextChanged), for: .editingChanged)
        }
    }
}
