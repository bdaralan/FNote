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
        
    var viewModel: CollectionViewWrapperViewModel
    
    /// A collection view to use.
    ///
    /// NOTE:
    /// - If given `nil`, the wrapper will create one.
    /// - Otherwise, the collection view must be setup and ready to be used.
    var collectionView: UICollectionView?
    
    
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
        
        
        init(wrapper: CollectionViewWrapper) {
            self.wrapper = wrapper
            collectionView = wrapper.collectionView ?? .init(frame: .zero, collectionViewLayout: .init())
            collectionView.backgroundColor = .clear
            
            super.init()
            if wrapper.collectionView == nil {
                wrapper.viewModel.setupCollectionView(collectionView)
            }
        }
    }
}


// MARK: - Coordinator Method

extension CollectionViewWrapper.Coordinator {
    
    func update(with wrapper: CollectionViewWrapper) {
        self.wrapper = wrapper
    }
}


// MARK: - View Model

protocol CollectionViewWrapperViewModel {
    
    /// The method called by the wrapper on init to setup the collection view.
    ///
    /// NOTE:
    /// - The wrapper only calls this method if the wrapper's `collectionView` is `nil`.
    /// - If the `collectionView` is not `nil`, the wrapper assumes the setup is done.
    func setupCollectionView(_ collectionView: UICollectionView)
}
