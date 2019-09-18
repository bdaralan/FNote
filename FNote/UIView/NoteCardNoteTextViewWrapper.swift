//
//  NoteCardNoteTextViewWrapper.swift
//  FNote
//
//  Created by Dara Beng on 9/16/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardNoteTextViewWrapper: UIViewRepresentable {
    
    @Binding var text: String
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = .preferredFont(forTextStyle: .body)
        textView.isEditable = false
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    
    // MARK: Coordinator
    
    class Coordinator: NSObject {
        
        override init() {
            super.init()
        }
    }
}
