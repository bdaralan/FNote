//
//  CollectionHeaderLabel.swift
//  FNote
//
//  Created by Dara Beng on 1/26/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class CollectionHeaderLabel: UICollectionReusableView {
    
    let label = UILabel(text: "Header")
    
    private var labelTopAnchor: NSLayoutConstraint!
    private var labelCenterYAnchor: NSLayoutConstraint!
    private var labelBottomAnchor: NSLayoutConstraint!
    
    enum LabelPosition {
        case top
        case center
        case bottom
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLabelPosition(_ position: LabelPosition) {
        switch position {
        case .top:
            labelCenterYAnchor.isActive = false
            labelBottomAnchor.isActive = false
            labelTopAnchor.isActive = true
        case .center:
            labelBottomAnchor.isActive = false
            labelTopAnchor.isActive = false
            labelCenterYAnchor.isActive = true
        case .bottom:
            labelCenterYAnchor.isActive = false
            labelTopAnchor.isActive = false
            labelBottomAnchor.isActive = true
        }
    }
}


extension CollectionHeaderLabel {
    
    private func setupView() {
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
    }
    
    private func setupConstraints() {
        addSubviews(label, useAutoLayout: true)
        
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        labelCenterYAnchor = label.centerYAnchor.constraint(equalTo: centerYAnchor)
        labelCenterYAnchor.isActive = true
        
        labelTopAnchor = label.topAnchor.constraint(equalTo: topAnchor)
        labelBottomAnchor = label.bottomAnchor.constraint(equalTo: bottomAnchor)
    }
}
