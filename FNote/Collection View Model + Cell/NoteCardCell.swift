//
//  NoteCardCell.swift
//  FNote
//
//  Created by Dara Beng on 1/17/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit
import Combine


class NoteCardCell: ManagedObjectCollectionViewCell<NoteCard> {
    
    // MARK: Action
    
    var onQuickButtonTapped: ((QuickButtonType, NoteCard) -> Void)?
    
    // MARK: UI Element
    let labelStackView = UIStackView()
    let quickButtonStackView = UIStackView()
    
    let translationLabel = UILabel(text: "Translation")
    let nativeLabel = UILabel(text: "Native")
    let dividerLine = UIView()
    let dividerLCircle = UIView()
    let dividerRCircle = UIView()
    
    let relationshipButton = UIButton(type: .system)
    let tagButton = UIButton(type: .system)
    let favoriteButton = UIButton(type: .system)
    let noteButton = UIButton(type: .system)
    
    var quickButtons: [UIButton] {
        [relationshipButton, tagButton, favoriteButton, noteButton]
    }
    
    private(set) var style: Style = .regular
    private let dividerCircleWidth: CGFloat = 5
    
    
    // MARK: Constraints
    
    var regularStyleConstraints: [NSLayoutConstraint] = []
    var shortStyleConstraints: [NSLayoutConstraint] = []
 
    
    // MARK: Method
    
    override func reload(with object: NoteCard) {
        super.reload(with: object)
        
        translationLabel.text = object.translation
        
        nativeLabel.text = object.native
        
        setDividerColor(object.formality.uiColor)
        setFavoriteButtonImage()
        
        noteButton.isUserInteractionEnabled = !object.note.isEmpty
        noteButton.tintColor = object.note.isEmpty ? .quaternaryLabel : .secondaryLabel
        
        relationshipButton.isUserInteractionEnabled = !object.relationships.isEmpty
        relationshipButton.tintColor = object.relationships.isEmpty ? .quaternaryLabel : .secondaryLabel
        
        tagButton.isUserInteractionEnabled = !object.tags.isEmpty
        tagButton.tintColor = object.tags.isEmpty ? .quaternaryLabel : .secondaryLabel
    }
    
    func setCellStyle(_ style: Style) {
        let isRegularInactive = regularStyleConstraints.map({ $0.isActive }).contains(false)
        let isShortInactive = shortStyleConstraints.map({ $0.isActive }).contains(false)
        let hasNoConstraints = isRegularInactive && isShortInactive
        
        guard self.style != style || hasNoConstraints else { return }
        NSLayoutConstraint.deactivate(regularStyleConstraints)
        NSLayoutConstraint.deactivate(shortStyleConstraints)
        
        switch style {
        case .regular:
            NSLayoutConstraint.activate(regularStyleConstraints)
            quickButtonStackView.isHidden = false
        case .short:
            NSLayoutConstraint.activate(shortStyleConstraints)
            quickButtonStackView.isHidden = true
        }
        
        layoutIfNeeded()
    }
    
    func showCellBorder(_ show: Bool) {
        layer.borderColor = UIColor.appAccent.cgColor
        layer.borderWidth = show ? 3 : 0
    }
    
    func disableCell(_ disabled: Bool) {
        isUserInteractionEnabled = disabled ? false : true
        contentView.layer.opacity = disabled ? 0.35 : 1
        layer.shadowOpacity = disabled ? 0 : 0.17
        backgroundColor = backgroundColor?.withAlphaComponent(disabled ? 0.35 : 1)
    }
    
    func setDividerColor(_ color: UIColor) {
        dividerLine.backgroundColor = color
        dividerLCircle.backgroundColor = color
        dividerRCircle.backgroundColor = color
    }
    
    func setQuickButtonImages() {
        relationshipButton.setImage(QuickButtonType.relationship.image, for: .normal)
        tagButton.setImage(QuickButtonType.tag.image, for: .normal)
        noteButton.setImage(QuickButtonType.note.image, for: .normal)
        setFavoriteButtonImage()
    }
    
    func setFavoriteButtonImage() {
        let isFavorite = object?.isFavorite == true
        let image = isFavorite ? QuickButtonType.favoriteImage : QuickButtonType.favorite.image
        favoriteButton.setImage(image, for: .normal)
    }
    
    @objc private func handleQuickButtonTapped(_ sender: UIButton) {
        guard let noteCard = object else { return }
        let type: QuickButtonType
        switch sender {
        case relationshipButton: type = .relationship
        case tagButton: type = .tag
        case noteButton: type = .note
        case favoriteButton: type = .favorite
        default: fatalError("🧨 handleQuickButtonTapped unknown button type 💣")
        }
        
        if sender === favoriteButton {
            UISelectionFeedbackGenerator().selectionChanged()
        }
        
        onQuickButtonTapped?(type, noteCard)
    }
    
    override func initCell() {
        super.initCell()
        setCellStyle(style)
        setQuickButtonImages()
    }
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = .noteCardBackground
        layer.masksToBounds = false
        layer.cornerRadius = 15
        layer.shadowColor = UIColor.label.cgColor
        layer.shadowOpacity = 0.17
        layer.shadowRadius = 1
        layer.shadowOffset = .init(width: -1, height: 1)
        
        nativeLabel.font = .preferredFont(forTextStyle: .title3)
        nativeLabel.adjustsFontForContentSizeCategory = true
        
        translationLabel.font = .preferredFont(forTextStyle: .body)
        translationLabel.adjustsFontForContentSizeCategory = true
        
        setDividerColor(NoteCard.Formality.unspecified.uiColor)
        dividerLCircle.layer.cornerRadius = dividerCircleWidth / 2
        dividerRCircle.layer.cornerRadius = dividerCircleWidth / 2
        
        for button in quickButtons {
            button.addTarget(self, action: #selector(handleQuickButtonTapped), for: .touchUpInside)
            button.tintColor = .secondaryLabel
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        contentView.addSubviews(labelStackView, quickButtonStackView, useAutoLayout: true)
        
        labelStackView.axis = .vertical
        labelStackView.spacing = 12
        labelStackView.distribution = .fillProportionally
        labelStackView.addArrangedSubviews(nativeLabel, dividerLine, translationLabel)
        
        dividerLine.addSubviews(dividerLCircle, dividerRCircle, useAutoLayout: true)
        
        quickButtonStackView.axis = .horizontal
        quickButtonStackView.spacing = 0
        quickButtonStackView.distribution = .fillEqually
        quickButtonStackView.addArrangedSubviews(relationshipButton, tagButton, favoriteButton, noteButton)
        
        let sharedConstraints = [
            labelStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            labelStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -16 * 2),
            labelStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            dividerLine.heightAnchor.constraint(equalToConstant: 1),
            
            dividerLCircle.centerYAnchor.constraint(equalTo: dividerLine.centerYAnchor),
            dividerLCircle.centerXAnchor.constraint(equalTo: dividerLine.leadingAnchor),
            dividerLCircle.heightAnchor.constraint(equalToConstant: dividerCircleWidth),
            dividerLCircle.widthAnchor.constraint(equalToConstant: dividerCircleWidth),
            
            dividerRCircle.centerYAnchor.constraint(equalTo: dividerLine.centerYAnchor),
            dividerRCircle.centerXAnchor.constraint(equalTo: dividerLine.trailingAnchor),
            dividerRCircle.heightAnchor.constraint(equalToConstant: dividerCircleWidth),
            dividerRCircle.widthAnchor.constraint(equalToConstant: dividerCircleWidth)
        ]
        
        regularStyleConstraints = sharedConstraints + [
            quickButtonStackView.topAnchor.constraint(lessThanOrEqualTo: labelStackView.bottomAnchor, constant: 12),
            quickButtonStackView.topAnchor.constraint(greaterThanOrEqualTo: labelStackView.bottomAnchor, constant: 4),
            quickButtonStackView.heightAnchor.constraint(equalToConstant: 35),
            quickButtonStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            quickButtonStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            quickButtonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ]
        
        shortStyleConstraints = sharedConstraints + [
            labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ]
    }
}


extension NoteCardCell {
    
    enum Style {
        case regular
        case short
        
        var height: CGFloat {
            switch self {
            case .regular: return 140
            case .short: return 105
            }
        }
    }
    
    enum QuickButtonType {
        case relationship
        case tag
        case favorite
        case note
            
        var image: UIImage {
            switch self {
            case .relationship: return Self.relationshipImage
            case .tag: return Self.tagImage
            case .favorite: return Self.unfavoriteImage
            case .note: return Self.noteImage
            }
        }
        
        static let relationshipImage = UIImage(systemName: "rectangle.on.rectangle")!.applyingSymbolConfiguration(.init(scale: .medium))!
        static let tagImage = UIImage(systemName: "tag")!.applyingSymbolConfiguration(.init(scale: .medium))!
        static let noteImage = UIImage(systemName: "doc.plaintext")!.applyingSymbolConfiguration(.init(scale: .medium))!
        static let unfavoriteImage = UIImage(systemName: "star")!.applyingSymbolConfiguration(.init(scale: .medium))!
        static let favoriteImage = UIImage(systemName: "star.fill")!.applyingSymbolConfiguration(.init(scale: .medium))!
    }
    
    enum ContextMenu {
        case copyNative
        case delete
        
        var title: String {
            switch self {
            case .copyNative: return "Copy Native"
            case .delete: return "Delete"
            }
        }
        
        var image: UIImage {
            switch self {
            case .copyNative: return UIImage(systemName: "doc.on.clipboard")!
            case .delete: return UIImage(systemName: "trash")!
            }
        }
    }
}
