//
//  ActionCollectionViewCell.swift
//  FNote
//
//  Created by Dara Beng on 3/15/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class ActionCollectionViewCell: UICollectionViewCell {
    
    let label = UILabel(text: "ACTION")
    
    var onTapped: ((ActionCollectionViewCell) -> Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAction(title: String, description: String? = nil) {
        guard let description = description else {
            label.text = title
            return
        }
        
        let string = "\(title)\n\(description)"
        let stringRange = NSRange(location: 0, length: string.count)
        let descriptionRange = NSRange(location: title.count + 1, length: description.count)
        let smallFont = UIFont.preferredFont(forTextStyle: .footnote)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 4
        
        let attrString = NSMutableAttributedString(string: string)
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: stringRange)
        attrString.addAttribute(.font, value: smallFont, range: descriptionRange)
        attrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: descriptionRange)
        
        label.attributedText = attrString
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        label.attributedText = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyCardStyle()
    }
    
    private func setupCell() {
        let font = UIFont.preferredFont(forTextStyle: .body)
        label.font = .systemFont(ofSize: font.fontDescriptor.pointSize, weight: .heavy)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .label
    }
    
    private func setupConstraints() {
        contentView.addSubviews(label, useAutoLayout: true)
            
        NSLayoutConstraint.activateConstraints(
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        )
    }
}
