//
//  NoteCardCellWrapper.swift
//  FNote
//
//  Created by Dara Beng on 1/17/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardCellWrapper: UIViewRepresentable {
    
    // MARK: Property
    
    var noteCard: NoteCard
    
    var style: NoteCardCell.Style
    
    var onQuickButtonTapped: ((NoteCardCell.QuickButtonType, NoteCard) -> Void)?
    
    
    // MARK: Make View
    
    func makeCoordinator() -> Coordinator {
        Coordinator(wrapper: self)
    }
    
    func makeUIView(context: Context) -> NoteCardCell {
        context.coordinator.cell
    }
    
    func updateUIView(_ uiView: NoteCardCell, context: Context) {
        context.coordinator.update(with: self)
    }
}


// MARK: - Coordinator

extension NoteCardCellWrapper {
    
    class Coordinator: NSObject {
        
        var wrapper: NoteCardCellWrapper
        
        let cell: NoteCardCell
        
        
        init(wrapper: NoteCardCellWrapper) {
            self.wrapper = wrapper
            cell = .init(frame: .init(x: 0, y: 0, width: 150, height: 100))
            cell.setCellStyle(wrapper.style)
        }
    }
}


// MARK: - Coordinator Method

extension NoteCardCellWrapper.Coordinator {
    
    func update(with wrapper: NoteCardCellWrapper) {
        self.wrapper = wrapper
        cell.onQuickButtonTapped = wrapper.onQuickButtonTapped
        cell.reload(with: wrapper.noteCard)
    }
}
