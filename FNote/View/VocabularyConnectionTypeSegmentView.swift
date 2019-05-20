//
//  VocabularyConnectionTypeSegmentView.swift
//  FNote
//
//  Created by Dara Beng on 4/5/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


class VocabularyConnectionTypeSegmentView: UIView {
    
    let connectionTypes: [VocabularyConnection.ConnectionType]
    
    var selectedConnectionType: VocabularyConnection.ConnectionType {
        return connectionTypes[segmentControl.selectedSegmentIndex]
    }
    
    let segmentControl = UISegmentedControl()
    
    
    init(types: [VocabularyConnection.ConnectionType]) {
        connectionTypes = types
        super.init(frame: .zero)
        setupView()
        setupSegmentControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension VocabularyConnectionTypeSegmentView {
    
    private func setupView() {
        addSubviews(segmentControl)
        
        let safeArea = safeAreaLayoutGuide
        NSLayoutConstraint.activate(
            segmentControl.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            segmentControl.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            segmentControl.heightAnchor.constraint(equalToConstant: 28)
        )
    }
    
    private func setupSegmentControl() {
        for (index, connectionType) in connectionTypes.enumerated() {
            segmentControl.insertSegment(withTitle: connectionType.displayText, at: index, animated: false)
        }
        segmentControl.selectedSegmentIndex = 0
    }
}
