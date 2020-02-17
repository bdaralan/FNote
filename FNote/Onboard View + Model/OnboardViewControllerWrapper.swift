//
//  OnboardViewControllerWrapper.swift
//  FNote
//
//  Created by Dara Beng on 2/17/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct OnboardViewControllerWrapper: UIViewControllerRepresentable {
    
    var viewModel: OnboardCollectionViewModel
    
    func makeUIViewController(context: Context) -> OnboardViewController {
        let controller = OnboardViewController(viewModel: viewModel)
        controller.view.backgroundColor = .clear
        controller.collectionView.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: OnboardViewController, context: Context) {
        // nothing right now
    }
}
