//
//  FNCollectionViewCell.swift
//  FNote
//
//  Created by Dara Beng on 1/17/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class FNCollectionViewCell<Object>: UICollectionViewCell {
    
    private(set) var object: Object?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        object = nil
    }
    
    func reload(with object: Object) {
        self.object = object
    }
    
    func initCell() {
        setupCell()
        setupConstraints()
    }
    
    func setupCell() {}
    
    func setupConstraints() {}
}
