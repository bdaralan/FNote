//
//  ModalTextView.swift
//  FNote
//
//  Created by Dara Beng on 9/15/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct ModalTextView: View {
    
    @Binding var isActive: Bool
    
    @Binding var text: String
    
    var prompt: String
    
    var onCommit: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(prompt)
                .font(.largeTitle)
                .bold()
            ModalTextViewWrapper(text: $text, isActive: $isActive)
//                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.vertical, 20)
        .padding(.horizontal)
        .overlay(dragHandle, alignment: .top)
    }
    
    var dragHandle: some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .frame(width: 40, height: 4, alignment: .center)
            .foregroundColor(.primary)
            .padding(.top, 8)
    }
}

struct ModalTextView_Previews: PreviewProvider {
    static var previews: some View {
        ModalTextView(isActive: .constant(true), text: .constant("Hello"), prompt: "Prompt", onCommit: nil)
    }
}
