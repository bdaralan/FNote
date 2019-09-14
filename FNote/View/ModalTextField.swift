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
    
    var tip = ""
    
    var onCommit: (() -> Void)?
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(prompt)
                .font(.largeTitle)
                .bold()
            ModalTextFieldWrapper(isActive: $isActive, text: $text, placeholder: placeholder, onCommit: onCommit)
                .fixedSize(horizontal: false, vertical: true)
            Divider()
            Text(tip)
                .foregroundColor(.secondary)
                .padding(.vertical)
                .padding(.vertical)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}
