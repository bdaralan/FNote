//
//  VocabularyCollectionViewTagCell.swift
//  FNote
//
//  Created by Dara Beng on 3/21/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


class VocabularyCollectionViewTagCell: UICollectionViewCell {
    
    let tagLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.lineBreakMode = .byTruncatingMiddle
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.bounds.height / 2
    }
    
    
    func reload(with tag: Tag) {
        tagLabel.text = tag.name
    }
}


extension VocabularyCollectionViewTagCell {
    
    private func setupCell() {
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.addSubviews([tagLabel])
        let safeArea = contentView.safeAreaLayoutGuide
        tagLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8).isActive = true
        tagLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8).isActive = true
        tagLabel.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tagLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
    }
}
