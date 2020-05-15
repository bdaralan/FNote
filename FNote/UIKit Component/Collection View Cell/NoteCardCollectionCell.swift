//
//  NoteCardCollectionCell.swift
//  FNote
//
//  Created by Dara Beng on 1/24/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit
import Combine


class NoteCardCollectionCell: ManagedObjectCollectionViewCell<NoteCardCollection> {
    
    let nameLabel = UILabel(text: "Collection")
    let cardCountLabel = UILabel(text: "0 CARDS")
    let iconImageView = UIImageView()
    
    private(set) var iconName: String?
    
    
    override func reload(with object: NoteCardCollection) {
        super.reload(with: object)
        nameLabel.text = object.name
        cardCountLabel.text = String(quantity: object.noteCards.count, singular: "CARD", plural: "CARDS")
    }
    
    func setIconImage(systemName: String?) {
        guard let name = systemName else {
            iconImageView.image = nil
            iconName = nil
            return
        }
        
        guard name != iconName else { return }
        let font = UIImage.SymbolConfiguration(textStyle: .body)
        let weight = UIImage.SymbolConfiguration(weight: .semibold)
        var image = UIImage(systemName: name)
        image = image?.applyingSymbolConfiguration(font)
        image = image?.applyingSymbolConfiguration(weight)
        iconImageView.image = image
    }
    
    func showCellBorder(_ show: Bool) {
        layer.borderColor = UIColor.appAccent.cgColor
        layer.borderWidth = show ? 3 : 0
    }
    
    /// Disable user interaction.
    /// - Parameters:
    ///   - disabled: A value indicate whether the cell should be disabled.
    ///   - faded: A value indicate whether the disabled cell should be faded.
    func disableCell(_ disabled: Bool) {
        isUserInteractionEnabled = disabled ? false : true
        contentView.layer.opacity = disabled ? 0.35 : 1
        layer.shadowOpacity = disabled ? 0 : 0.17
        backgroundColor = backgroundColor?.withAlphaComponent(disabled ? 0.35 : 1)
    }
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = .noteCardBackground
        layer.masksToBounds = false
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.label.cgColor
        layer.shadowOpacity = 0.17
        layer.shadowRadius = 1
        layer.shadowOffset = .init(width: -1, height: 1)
        
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.textColor = .label
        nameLabel.adjustsFontForContentSizeCategory = true
        
        cardCountLabel.font = .preferredFont(forTextStyle: .callout)
        cardCountLabel.textColor = .secondaryLabel
        cardCountLabel.adjustsFontForContentSizeCategory = true
        
        iconImageView.tintColor = .label
        iconImageView.contentMode = .scaleAspectFit
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        let labelVStack = UIStackView(arrangedSubviews: [nameLabel, cardCountLabel])
        labelVStack.axis = .vertical
        labelVStack.spacing = 0
        labelVStack.distribution = .fillProportionally
        
        contentView.addSubviews(labelVStack, iconImageView, useAutoLayout: true)
        
        NSLayoutConstraint.activateConstraints(
            labelVStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelVStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelVStack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            labelVStack.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            labelVStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 20)
        )
    }
}
