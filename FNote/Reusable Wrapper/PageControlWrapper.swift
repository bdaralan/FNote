//
//  PageControlWrapper.swift
//  FNote
//
//  Created by Dara Beng on 2/14/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct PageControlWrapper: UIViewRepresentable {
    
    // MARK: Property
    
    @Binding var currentPage: Int
    
    var pageCount: Int
    
    var configure: ((UIPageControl) -> Void)?
    
    
    // MARK: Make View
    
    func makeCoordinator() -> Coordinator {
        Coordinator(wrapper: self)
    }
    
    func makeUIView(context: Context) -> UIPageControl {
        context.coordinator.pageControl
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        context.coordinator.update(with: self)
    }
}


// MARK: - Coordinator

extension PageControlWrapper {
    
    class Coordinator: NSObject {
        
        var wrapper: PageControlWrapper
        
        let pageControl = UIPageControl()
        
        
        init(wrapper: PageControlWrapper) {
            self.wrapper = wrapper
            wrapper.configure?(pageControl)
            super.init()
            update(with: wrapper)
        }
    }
}


// MARK: - Coordinator Method

extension PageControlWrapper.Coordinator {
    
    func update(with wrapper: PageControlWrapper) {
        self.wrapper = wrapper
        pageControl.currentPage = wrapper.currentPage
        pageControl.numberOfPages = wrapper.pageCount
    }
}
