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
    
    let titleLabel = UILabel(text: "Title")
    let descriptionTextView = UITextView()
    let languageLabel = UILabel(text: "ENG - ENG")
    let countLabel = UILabel(text: "0 CARDS")
    let tagLabel = UILabel(text: "Tags: One, Two, Three")
    let authorLabel = UILabel(text: "by Author")
    
    let firstDivider = DividerLine()
    let secondDivider = DividerLine()
    
    let voteButton = UIButton(type: .system)
    
    @Published var voted = false
    
    private var cancellables: [AnyCancellable] = []
    
    
    override func reload(with object: PublicCollection) {
        super.reload(with: object)
        titleLabel.text = object.name
        languageLabel.text = "\(object.primaryLanguage) - \(object.secondaryLanguage)"
        setAuthor(name: "----")
        
        let countUnit = object.cardsCount == 1 ? "CARD" : "CARDS"
        countLabel.text = "\(object.cardsCount) \(countUnit)"
        
        descriptionTextView.text = object.description
        
        let tagPrefix = "Tags:"
        let tagText = "\(tagPrefix) \(object.tags.joined(separator: ", "))"
        let tagAttrString = NSMutableAttributedString(string: tagText)
        let tagRange = NSRange(location: 0, length: tagPrefix.count)
        tagAttrString.setAttributes([.font : languageLabel.font as Any], range: tagRange)
        tagLabel.attributedText = tagAttrString
        
        setupVoteSubscription()
    }
    
    func setAuthor(name: String) {
        authorLabel.text = "by \(name)"
    }
    
    private func setupVoteSubscription() {
        $voted
            .eraseToAnyPublisher()
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { voted in
                let symbol = UIImage.SymbolConfiguration(textStyle: .body)
                let imageName = voted ? "hand.thumbsup.fill" : "hand.thumbsup"
                let image = UIImage(systemName: imageName, withConfiguration: symbol)
                self.voteButton.setImage(image, for: .normal)
                self.voteButton.tintColor = voted ? .label : .secondaryLabel
            })
            .store(in: &cancellables)
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
        var languageFD = footnoteFont.fontDescriptor
        languageFD = languageFD.withSymbolicTraits(.traitBold) ?? languageFD
        languageLabel.font = UIFont(descriptor: languageFD, size: languageFD.pointSize)
        languageLabel.adjustsFontForContentSizeCategory = true
        
        authorLabel.font = footnoteFont
        authorLabel.textColor = .secondaryLabel
        authorLabel.adjustsFontForContentSizeCategory = true
        
        countLabel.font = footnoteFont
        countLabel.textColor = .secondaryLabel
        countLabel.adjustsFontForContentSizeCategory = true
        
        descriptionTextView.font = footnoteFont
        descriptionTextView.isEditable = false
        descriptionTextView.isSelectable = false
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
        voted.toggle()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        contentView.addSubviews(
            titleLabel, languageLabel, authorLabel, countLabel,
            firstDivider,
            descriptionTextView,
            secondDivider, tagLabel,
            voteButton,
            useAutoLayout: true
        )
        
        NSLayoutConstraint.activateConstraints(
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: languageLabel.leadingAnchor, constant: -8),
            
            languageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            languageLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: countLabel.leadingAnchor, constant: -8),
            
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            countLabel.centerYAnchor.constraint(equalTo: authorLabel.centerYAnchor),
            
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
        
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        
        authorLabel.setContentHuggingPriority(.required, for: .vertical)
        
        descriptionTextView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        languageLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        languageLabel.setContentHuggingPriority(.required, for: .horizontal)
        languageLabel.setContentHuggingPriority(.required, for: .vertical)
        
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        countLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        tagLabel.setContentHuggingPriority(.required, for: .vertical)
        
        voteButton.setContentHuggingPriority(.required, for: .horizontal)
        voteButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}



