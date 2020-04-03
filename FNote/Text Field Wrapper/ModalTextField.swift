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
            // MARK: Title & Text Field
            VStack(alignment: .leading) {
                
                HStack(alignment: .firstTextBaseline) {
                    Text(viewModel.title)
                        .font(.largeTitle)
                        .bold()
                        .lineLimit(1)
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
            
            // MARK: Prompt & Token
            VStack(alignment: .leading, spacing: 16) {
                if !viewModel.prompt.isEmpty {
                    Text(viewModel.prompt)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(viewModel.promptColor ?? .secondary)
                        .padding(.horizontal, 20)
                }
                
                if !viewModel.tokens.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.tokens, id: \.self) { token in
                                ModalTextFieldTokenView(
                                    token: token,
                                    showClear: self.viewModel.showClearTokenIndicator,
                                    onSelected: self.viewModel.onTokenSelected
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
    
    func configureTextField(_ textField: UITextField) {
        textField.returnKeyType = viewModel.returnKeyType
    }
}


// MARK: - Token View

struct ModalTextFieldTokenView: View {
    
    var token: String
    
    var showClear: Bool
    
    var onSelected: ((String) -> Void)?
    
    
    var body: some View {
        HStack(spacing: 8) {
            Text(token)
            if showClear {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.secondary)
                    .font(.body)
            }
        }
        .padding(.vertical, 8)
        .padding(.leading, 16)
        .padding(.trailing, showClear ? 12 : 16)
        .background(Color.noteCardBackground)
        .cornerRadius(30)
        .onTapGesture(perform: { self.onSelected?(self.token) })
    }
}


// MARK: - Preview

struct ModalTextField_Previews: PreviewProvider {
    
    static var model: ModalTextFieldModel = {
        var model = ModalTextFieldModel()
        model.title = "Title"
        model.placeholder = "placeholder"
        model.text = "text"
        model.tokens = ["ABC", "DEF", "GHIJK"]
        model.showClearTokenIndicator = true
        model.onTokenSelected = { _ in }
        model.onCancel = {}
        return model
    }()
    
    static var previews: some View {
        ModalTextField(viewModel: .constant(model))
    }
}
