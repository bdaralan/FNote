//
//  LabelCollectionHeader.swift
//  FNote
//
//  Created by Dara Beng on 1/26/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class LabelCollectionHeader: UICollectionReusableView {
    
    let label = UILabel(text: "Header")
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension LabelCollectionHeader {
    
    private func setupView() {
        
    }
    
    private func setupConstraints() {
        
    }
}
