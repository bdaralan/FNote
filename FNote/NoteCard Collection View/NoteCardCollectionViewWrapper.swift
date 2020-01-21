//
//  NoteCardCollectionViewWrapper.swift
//  FNote
//
//  Created by Dara Beng on 1/19/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct NoteCardCollectionViewWrapper: UIViewRepresentable {
    
    // MARK: Property
        
    var viewModel: NoteCardCollectionViewModel
    
    
    // MARK: Make View
    
    func makeCoordinator() -> Coordinator {
        Coordinator(wrapper: self)
    }
    
    func makeUIView(context: Context) -> UICollectionView {
        context.coordinator.collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        context.coordinator.update(with: self)
    }
}


// MARK: - Coordinator

extension NoteCardCollectionViewWrapper {
    
    class Coordinator: NSObject {
        
        var wrapper: NoteCardCollectionViewWrapper
        
        let collectionView: UICollectionView
        
        var viewModel: NoteCardCollectionViewModel {
            wrapper.viewModel
        }
        
        
        init(wrapper: NoteCardCollectionViewWrapper) {
            self.wrapper = wrapper
            collectionView = .init(frame: .zero, collectionViewLayout: .init())
            collectionView.backgroundColor = .clear
            
            super.init()
            viewModel.setupCollectionView(collectionView)
            viewModel.updateSnapshot(animated: false, completion: nil)
        }
    }
}


// MARK: - Coordinator Method

extension NoteCardCollectionViewWrapper.Coordinator {
    
    func update(with wrapper: NoteCardCollectionViewWrapper) {
        self.wrapper = wrapper
    }
}
