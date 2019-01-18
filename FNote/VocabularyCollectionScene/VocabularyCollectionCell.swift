//
//  VocabularyCollectionCell.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit

class VocabularyCollectionCell: UICollectionViewCell {
    
    static let defaultHeight: CGFloat = 120
    
    let formalityImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .red
        return view
    }()
    
    let favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Fav", for: .normal)
        return btn
    }()
    
    let relationButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Rel", for: .normal)
        return btn
    }()
    
    let alternativeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Alt", for: .normal)
        return btn
    }()
    
    let originalLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .title1)
        lbl.text = "안녕하세요"
        return lbl
    }()
    
    let translationLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .title1)
        lbl.text = "Hello"
        return lbl
    }()
    
    let buttonStackView: UIStackView = {
        let view = UIStackView()
        return view
    }()
    
    let seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
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
        formalityImageView.layer.cornerRadius = formalityImageView.frame.height / 2
    }
}


extension VocabularyCollectionCell {
    
    private func setupCell() {
        setupConstraints()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 15
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowColor = UIColor.black.cgColor
    }
    
    private func setupConstraints() {
        contentView.addSubviews([formalityImageView, translationLabel, originalLabel, favoriteButton, buttonStackView, seperatorView])
        buttonStackView.addArrangedSubview(alternativeButton)
        buttonStackView.addArrangedSubview(relationButton)
        
        let safeArea = contentView.safeAreaLayoutGuide
        let constraints = [
            formalityImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 11),
            formalityImageView.centerYAnchor.constraint(equalTo: translationLabel.centerYAnchor),
            formalityImageView.heightAnchor.constraint(equalToConstant: 15),
            formalityImageView.widthAnchor.constraint(equalTo: formalityImageView.heightAnchor),
            
            favoriteButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -11),
            favoriteButton.centerYAnchor.constraint(equalTo: translationLabel.centerYAnchor),
            favoriteButton.heightAnchor.constraint(equalToConstant: 35),
            favoriteButton.widthAnchor.constraint(equalTo: favoriteButton.heightAnchor),
            
            translationLabel.leadingAnchor.constraint(equalTo: formalityImageView.trailingAnchor, constant: 8),
            translationLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            
            seperatorView.topAnchor.constraint(equalTo: translationLabel.bottomAnchor, constant: 4),
            seperatorView.leadingAnchor.constraint(equalTo: formalityImageView.leadingAnchor),
            seperatorView.trailingAnchor.constraint(equalTo: favoriteButton.trailingAnchor),
            seperatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            originalLabel.topAnchor.constraint(equalTo: seperatorView.bottomAnchor, constant: 8),
            originalLabel.leadingAnchor.constraint(equalTo: formalityImageView.leadingAnchor),
            
            buttonStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            buttonStackView.trailingAnchor.constraint(equalTo: favoriteButton.trailingAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 30)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
