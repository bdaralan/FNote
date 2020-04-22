//
//  OnboardCell.swift
//  FNote
//
//  Created by Dara Beng on 2/13/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class OnboardCell: ObjectCollectionViewCell<OnboardPage> {
    
    let titleLabel = UILabel(text: "Title")
    let imageView = UIImageView()
    let descriptionLabel = UILabel(text: "Description")
    
    override func reload(with object: OnboardPage) {
        super.reload(with: object)
        if traitCollection.verticalSizeClass == .compact {
            titleLabel.text = object.titleCompact ?? object.title
            descriptionLabel.text = object.descriptionCompact ?? object.description
        } else {
            titleLabel.text = object.title
            descriptionLabel.text = object.description
        }
    }
    
    override func setupCell() {
        super.setupCell()
        let titleFont = UIFont.preferredFont(forTextStyle: .largeTitle)
        var titleDescriptor: UIFontDescriptor = titleFont.fontDescriptor
        titleDescriptor = titleDescriptor.withDesign(.rounded) ?? titleDescriptor
        titleDescriptor = titleDescriptor.withSymbolicTraits(.traitBold) ?? titleDescriptor
        titleLabel.font = UIFont(descriptor: titleDescriptor, size: titleDescriptor.pointSize)
        
        let descriptionFont = UIFont.preferredFont(forTextStyle: .title3)
        var descriptionDescriptor: UIFontDescriptor = descriptionFont.fontDescriptor
        descriptionDescriptor = descriptionDescriptor.withDesign(.rounded) ?? descriptionDescriptor
        descriptionLabel.font = UIFont(descriptor: descriptionDescriptor, size: descriptionDescriptor.pointSize)
        
        for label in [titleLabel, descriptionLabel] {
            label.textAlignment = .center
            label.numberOfLines = 3
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.6
            label.textColor = .white
        }
        
        imageView.contentMode = .scaleAspectFit
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        contentView.addSubviews(titleLabel, imageView, descriptionLabel, useAutoLayout: true)
        
        NSLayoutConstraint.activateConstraints(
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
    
            titleLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -16),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -40),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 20),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            descriptionLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -40)
        )
    }
}
