//
//  SegmentControlWrapper.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct SegmentControlWrapper: UIViewRepresentable {
    
    // MARK: Property
    
    @Binding var selectedIndex: Int
    
    var segments: [String]
    
    var selectedTintColor: UIColor?
    
    
    // MARK: Make View
    
    func makeCoordinator() -> Coordinator {
        Coordinator(wrapper: self)
    }
    
    func makeUIView(context: Context) -> UISegmentedControl {
        context.coordinator.segmentControl
    }
    
    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        context.coordinator.update(with: self)
    }
}


// MARK: - Coordinator

extension SegmentControlWrapper {
    
    class Coordinator: NSObject {
        
        var wrapper: SegmentControlWrapper
        
        let segmentControl: UISegmentedControl
        
        
        init(wrapper: SegmentControlWrapper) {
            self.wrapper = wrapper
            segmentControl = .init(items: wrapper.segments)
            
            super.init()
            segmentControl.addTarget(self, action: #selector(handleSegmentChanged), for: .valueChanged)
        }
    }
}


// MARK: - Coordinator Method

extension SegmentControlWrapper.Coordinator {
    
    func update(with wrapper: SegmentControlWrapper) {
        self.wrapper = wrapper
        segmentControl.selectedSegmentIndex = wrapper.selectedIndex
        segmentControl.selectedSegmentTintColor = wrapper.selectedTintColor
    }
    
    @objc private func handleSegmentChanged() {
        wrapper.selectedIndex = segmentControl.selectedSegmentIndex
    }
}
