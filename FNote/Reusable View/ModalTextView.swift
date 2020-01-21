//
//  ModalTextView.swift
//  FNote
//
//  Created by Dara Beng on 9/15/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct ModalTextView: View {
    
    @Binding var viewModel: ModalTextViewModel
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Text(viewModel.title)
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: viewModel.onCommit ?? {}) {
                    Text("Done").bold()
                }
            }
            ModalTextViewWrapper(
                text: $viewModel.text,
                isFirstResponder: $viewModel.isFirstResponder,
                disableEditing: viewModel.disableEditing,
                renderMarkdown: viewModel.renderMarkdown
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.vertical, 20)
        .padding(.horizontal)
        .overlay(dragHandle, alignment: .top)
    }
}


extension ModalTextView {
    
    var dragHandle: some View {
        ModalDragHandle(hideOnLandscape: true)
            .padding(.top, 8)
    }
}


struct ModalTextView_Previews: PreviewProvider {
    static var previews: some View {
        ModalTextView(viewModel: .constant(.init()))
    }
}
