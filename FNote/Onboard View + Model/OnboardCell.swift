//
//  OnboardCell.swift
//  FNote
//
//  Created by Dara Beng on 2/13/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class OnboardCell: FNCollectionViewCell<OnboardPage> {
    
    let titleLabel = UILabel(text: "Title")
    let imageView = UIImageView()
    let descriptionLabel = UILabel(text: "Description")
    
    override func reload(with object: OnboardPage) {
        super.reload(with: object)
        titleLabel.text = object.title
        titleLabel.textColor = UIColor(hex: object.foregroundColor)
        
        descriptionLabel.text = object.description
        descriptionLabel.textColor = titleLabel.textColor
        
        imageView.image = UIImage(systemName: "photo")?.applyingSymbolConfiguration(.init(scale: .large))
        
        backgroundColor = UIColor(hex: object.backgroundColor)
    }
    
    override func setupCell() {
        super.setupCell()
        let titleFont = UIFont.preferredFont(forTextStyle: .largeTitle)
        var titleDescriptor: UIFontDescriptor = titleFont.fontDescriptor
        titleDescriptor = titleDescriptor.withDesign(.rounded) ?? titleDescriptor
        titleDescriptor = titleDescriptor.withSymbolicTraits(.traitBold) ?? titleDescriptor
        titleLabel.font = UIFont(descriptor: titleDescriptor, size: titleDescriptor.pointSize)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 3
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.6
        
        let descriptionFont = UIFont.preferredFont(forTextStyle: .title1)
        var descriptionDescriptor: UIFontDescriptor = descriptionFont.fontDescriptor
        descriptionDescriptor = descriptionDescriptor.withDesign(.rounded) ?? descriptionDescriptor
        descriptionLabel.font = UIFont(descriptor: descriptionDescriptor, size: descriptionDescriptor.pointSize)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 3
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.minimumScaleFactor = 0.6
        
        imageView.contentMode = .scaleAspectFit
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        contentView.addSubviews(titleLabel, imageView, descriptionLabel, useAutoLayout: true)
        
        NSLayoutConstraint.activateConstraints(
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -40),
            imageView.heightAnchor.constraint(equalToConstant: 200),
    
            titleLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -16),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 20),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor)
        )
    }
}
