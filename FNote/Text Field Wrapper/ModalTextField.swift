//
//  TextFieldModalView.swift
//  FNote
//
//  Created by Dara Beng on 9/11/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct ModalTextField: View {
    
    @Binding var viewModel: ModalTextFieldModel
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Text(viewModel.title)
                    .font(.largeTitle)
                    .bold()
                if viewModel.onCancel != nil {
                    Spacer()
                    Button("Cancel", action: viewModel.onCancel!)
                }
            }
            
            TextFieldWrapper(
                isActive: $viewModel.isFirstResponder,
                text: $viewModel.text,
                placeholder: viewModel.placeholder,
                onCommit: viewModel.onCommit
            )
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
            
            Text(viewModel.prompt)
                .foregroundColor(viewModel.promptColor ?? .secondary)
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
