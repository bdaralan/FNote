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
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Text(viewModel.title)
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                    HStack(spacing: 16) {
                        viewModel.onCancel.map { action in
                            Button("Cancel", action: action)
                        }
                        
                        viewModel.onCommit.map { action in
                            Button(action: action) {
                                Text("Done").bold()
                            }
                        }
                    }
                }
                
                TextFieldWrapper(
                    isActive: $viewModel.isFirstResponder,
                    text: $viewModel.text,
                    placeholder: viewModel.placeholder,
                    onCommit: viewModel.onReturnKey,
                    configure: configureTextField
                )
                    .fixedSize(horizontal: false, vertical: true)
                
                Divider()
            }
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                if !viewModel.prompt.isEmpty {
                    Text(viewModel.prompt)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(viewModel.promptColor ?? .secondary)
                        .padding(.horizontal, 20)
                }
                
                if !viewModel.tokens.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.tokens, id: \.self) { token in
                                ModalTextFieldTokenView(
                                    token: token,
                                    onClear: { self.handleTokenClear(token) }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.vertical, 20)
        .overlay(dragHandle, alignment: .top)
    }
}


extension ModalTextField {
    
    var dragHandle: some View {
            ModalDragHandle(hideOnLandscape: true)
                .padding(.top, 8)
    }
    
    func handleTokenClear(_ token: String) {
        viewModel.onTokenSelected?(token)
    }
    
    func configureTextField(_ textField: UITextField) {
        textField.returnKeyType = viewModel.returnKeyType
    }
}


struct ModalTextFieldTokenView: View {
    
    var token: String
    
    var onClear: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 8) {
            Text(token)
            Image(systemName: "xmark.circle")
                .foregroundColor(.secondary)
                .font(.footnote)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.noteCardBackground)
        .cornerRadius(30)
        .onTapGesture(perform: onClear ?? {})
    }
}
