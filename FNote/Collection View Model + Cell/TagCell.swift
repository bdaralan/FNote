//
//  TagCell.swift
//  FNote
//
//  Created by Dara Beng on 1/26/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class TagCell: FNCollectionViewCell<Tag> {
    
    let nameLabel = UILabel(text: "Tag")
    let cardCountLabel = UILabel(text: "0 CARDS")
    
    
    override func reload(with object: Tag) {
        super.reload(with: object)
        
        nameLabel.text = object.name
        
        let count = object.noteCards.count
        let unit = count == 1 ? "CARD" : "CARDS"
        cardCountLabel.text = "\(count) \(unit)"
    }
    
    func showCellBorder(_ show: Bool) {
        layer.borderColor = UIColor.appAccent.cgColor
        layer.borderWidth = show ? 3 : 0
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
        
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        nameLabel.textColor = .label
        nameLabel.adjustsFontForContentSizeCategory = true
        
        cardCountLabel.font = .preferredFont(forTextStyle: .callout)
        cardCountLabel.textColor = .secondaryLabel
        cardCountLabel.adjustsFontForContentSizeCategory = true
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        let labelHStack = UIStackView(arrangedSubviews: [nameLabel, cardCountLabel])
        labelHStack.axis = .horizontal
        labelHStack.spacing = 8
        labelHStack.distribution = .fill
        
        addSubviews(labelHStack, useAutoLayout: true)
        
        NSLayoutConstraint.activateConstraints(
            labelHStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            labelHStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            labelHStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            labelHStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        )
    }
}


extension TagCell {
    
    enum ContextMenu {
        case rename
        case delete
        
        var title: String {
            switch self {
            case .rename: return "Rename"
            case .delete: return "Delete"
            }
        }
        
        var image: UIImage {
            switch self {
            case .rename: return UIImage(systemName: "square.and.pencil")!
            case .delete: return UIImage(systemName: "trash")!
            }
        }
    }
}
