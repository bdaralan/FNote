//
//  CollectionViewWrapper.swift
//  FNote
//
//  Created by Dara Beng on 1/24/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct CollectionViewWrapper: UIViewRepresentable {
    
    // MARK: Property
        
    var viewModel: CollectionViewCompositionalViewModel
    
    
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

extension CollectionViewWrapper {
    
    class Coordinator: NSObject {
        
        var wrapper: CollectionViewWrapper
        
        let collectionView: UICollectionView
        
        var viewModel: CollectionViewCompositionalViewModel {
            wrapper.viewModel
        }
        
        
        init(wrapper: CollectionViewWrapper) {
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

extension CollectionViewWrapper.Coordinator {
    
    func update(with wrapper: CollectionViewWrapper) {
        self.wrapper = wrapper
    }
}
