//
//  CollectionViewSectionHeader.swift
//  FNote
//
//  Created by Dara Beng on 4/5/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit

class CollectionViewSectionHeader: UICollectionReusableView {
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        return lbl
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension CollectionViewSectionHeader {
    
    private func setupView() {
        addSubviews([titleLabel])
        let safeArea = safeAreaLayoutGuide
        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
