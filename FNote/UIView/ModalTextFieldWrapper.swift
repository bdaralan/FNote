//
//  ModalTextFieldWrapper.swift
//  FNote
//
//  Created by Dara Beng on 9/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct ModalTextFieldWrapper: UIViewRepresentable {
    
    @Binding var isActive: Bool
    
    @Binding var text: String
    
    var placeholder: String
    
    var onCommit: (() -> Void)?
    
    
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
        
        var wrapper: ModalTextFieldWrapper
        
        let textField = UITextField()

        
        init(wrapper: ModalTextFieldWrapper) {
            self.wrapper = wrapper
            super.init()
            setupTextField()
        }
    
        
        func update(with wrapper: ModalTextFieldWrapper) {
            self.wrapper = wrapper
            textField.text = wrapper.text
            textField.placeholder = wrapper.placeholder
            setActive(to: wrapper.isActive, for: textField)
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            wrapper.onCommit?()
            return true
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
        }
        
        @objc private func handleEditingChanged(_ sender: UITextField) {
            wrapper.text = sender.text!
        }
    }
}
