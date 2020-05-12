//
//  PublicCollectionCell.swift
//  FNote
//
//  Created by Dara Beng on 2/27/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit
import Combine


class PublicCollectionCell: ObjectCollectionViewCell<PublicCollection> {
    
    let titleLabel = UILabel()
    let descriptionTextView = UITextView()
    let languageLabel = UILabel()
    let cardCountLabel = UILabel()
    let tagLabel = UILabel()
    let authorLabel = UILabel()
    let createDateLabel = UILabel()
    
    let firstDivider = DividerLine()
    let secondDivider = DividerLine()
    
    let voteButton = UIButton(type: .system)
    
    var onVoteTriggered: ((PublicCollectionCell) -> Void)?
    
    
    override func reload(with object: PublicCollection) {
        super.reload(with: object)
        titleLabel.text = object.name
        
        languageLabel.text = "\(object.primaryLanguage.localized) - \(object.secondaryLanguage.localized)"
        
        cardCountLabel.text = String(quantity: object.cardsCount, singular: "CARD", plural: "CARDS")
        
        let author = object.authorName.isEmpty ? "----" : object.authorName
        authorLabel.text = "by \(author)"
        
        if let createDate = object.record?.creationDate {
            createDateLabel.text = Self.dateFormatter.string(from: createDate)
        } else {
            createDateLabel.text = "???"
        }
        
        descriptionTextView.text = object.description
        
        let tagPrefix = "Tags:"
        let tagText = "\(tagPrefix) \(object.tags.joined(separator: ", "))"
        let tagAttrString = NSMutableAttributedString(string: tagText)
        let tagRange = NSRange(location: 0, length: tagPrefix.count)
        tagAttrString.setAttributes([.font : languageLabel.font as Any], range: tagRange)
        tagLabel.attributedText = tagAttrString
        
        setVoted(object.localVoted)
    }
    
    private func setVoted(_ voted: Bool) {
        let symbol = UIImage.SymbolConfiguration(textStyle: .body)
        let imageName = voted ? "hand.thumbsup.fill" : "hand.thumbsup"
        let image = UIImage(systemName: imageName, withConfiguration: symbol)
        voteButton.setImage(image, for: .normal)
        voteButton.tintColor = voted ? .label : .secondaryLabel
    }
    
    func placeholder() {
        titleLabel.text = "----"
        descriptionTextView.text = "----"
        languageLabel.text = "----"
        cardCountLabel.text = "----"
        tagLabel.text = "----"
        authorLabel.text = "----"
        createDateLabel.text = "----"
        setVoted(false)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onVoteTriggered = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyCardStyle()
    }
    
    override func setupCell() {
        super.setupCell()
        
        let titleFont = UIFont.preferredFont(forTextStyle: .body)
        var titleFD = titleFont.fontDescriptor
        titleFD = titleFD.withSymbolicTraits(.traitBold) ?? titleFD
        titleLabel.font = UIFont(descriptor: titleFD, size: titleFD.pointSize)
        titleLabel.adjustsFontForContentSizeCategory = true
        
        let footnoteFont = UIFont.preferredFont(forTextStyle: .footnote)
        languageLabel.font = footnoteFont
        languageLabel.textColor = .label
        languageLabel.adjustsFontForContentSizeCategory = true
        
        cardCountLabel.font = footnoteFont
        cardCountLabel.textColor = .secondaryLabel
        cardCountLabel.adjustsFontForContentSizeCategory = true
        
        authorLabel.font = footnoteFont
        authorLabel.textColor = .secondaryLabel
        authorLabel.adjustsFontForContentSizeCategory = true
        
        createDateLabel.font = footnoteFont
        createDateLabel.textColor = .secondaryLabel
        
        descriptionTextView.font = footnoteFont
        descriptionTextView.isUserInteractionEnabled = false
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.adjustsFontForContentSizeCategory = true
        
        tagLabel.font = footnoteFont
        tagLabel.textColor = .label
        tagLabel.adjustsFontForContentSizeCategory = true
        
        firstDivider.setColor(.noteCardDivider)
        secondDivider.setColor(.noteCardDivider)
        
        voteButton.addTarget(self, action: #selector(handleVoteButtonTapped), for: .touchUpInside)
        voteButton.adjustsImageSizeForAccessibilityContentSizeCategory = false
    }
    
    @objc private func handleVoteButtonTapped() {
        onVoteTriggered?(self)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        contentView.addSubviews(
            titleLabel, languageLabel, cardCountLabel, authorLabel, createDateLabel,
            firstDivider,
            descriptionTextView,
            secondDivider, tagLabel,
            voteButton,
            useAutoLayout: true
        )
        
        NSLayoutConstraint.activateConstraints(
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            languageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            languageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            languageLabel.trailingAnchor.constraint(equalTo: cardCountLabel.leadingAnchor, constant: -8),
            
            cardCountLabel.centerYAnchor.constraint(equalTo: languageLabel.centerYAnchor),
            cardCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            authorLabel.topAnchor.constraint(equalTo: languageLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: cardCountLabel.leadingAnchor, constant: -8),
            
            createDateLabel.centerYAnchor.constraint(equalTo: authorLabel.centerYAnchor),
            createDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            firstDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            firstDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            firstDivider.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            firstDivider.heightAnchor.constraint(equalToConstant: 5),
            
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            descriptionTextView.topAnchor.constraint(equalTo: firstDivider.bottomAnchor, constant: 0),
            descriptionTextView.bottomAnchor.constraint(equalTo: secondDivider.topAnchor, constant: -0),
            
            secondDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            secondDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            secondDivider.bottomAnchor.constraint(equalTo: tagLabel.topAnchor, constant: -8),
            secondDivider.heightAnchor.constraint(equalToConstant: 5),
            
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tagLabel.trailingAnchor.constraint(equalTo: voteButton.leadingAnchor, constant: -8),
            tagLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            voteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            voteButton.centerYAnchor.constraint(equalTo: tagLabel.centerYAnchor)
        )
        
//        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        
        cardCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        cardCountLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        createDateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        createDateLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        voteButton.setContentHuggingPriority(.required, for: .horizontal)
        voteButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}


// MARK: - Date Formatter

extension PublicCollectionCell {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.doesRelativeDateFormatting = true
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter
    }()
}


// MARK: - Preview

//import SwiftUI
//
//struct PreviewWrapper: UIViewRepresentable {
//
//    typealias UIViewType = PublicCollectionCell
//
//    func makeUIView(context: Context) -> UIViewType {
//        let uiView = UIViewType()
//        return uiView
//    }
//
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//        uiView.reload(with: PublicCollectionDetailViewHeader_Previews.collection)
//    }
//}
//
//struct PreviewWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewWrapper()
//    }
//}
