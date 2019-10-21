//
//  TextFieldModalView.swift
//  FNote
//
//  Created by Dara Beng on 9/11/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct ModalTextField: View {
        
    @Binding var isActive: Bool
    
    @Binding var text: String
    
    var prompt: String
    
    var placeholder: String
    
    var description = ""
    
    var descriptionColor = Color.secondary
    
    var onCommit: (() -> Void)?
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(prompt)
                .font(.largeTitle)
                .bold()
            ModalTextFieldWrapper(isActive: $isActive, text: $text, placeholder: placeholder, onCommit: onCommit)
                .fixedSize(horizontal: false, vertical: true)
            Divider()
            Text(description)
                .foregroundColor(descriptionColor)
                .padding(.vertical)
                .padding(.vertical)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.vertical, 20)
        .padding(.horizontal)
        .overlay(dragHandle, alignment: .top)
    }
}


extension ModalTextField {
    var dragHandle: some View {
            ModalDragHandle(hideOnLandscape: true)
            .padding(.top, 8)
    }
}
