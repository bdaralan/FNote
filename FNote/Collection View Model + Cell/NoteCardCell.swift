//
//  NoteCardCell.swift
//  FNote
//
//  Created by Dara Beng on 1/17/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit
import Combine


class NoteCardCell: FNCollectionViewCell<NoteCard> {
    
    // MARK: Action
    
    var onQuickButtonTapped: ((QuickButtonType, NoteCard) -> Void)?
    
    // MARK: UI Element
    let labelStackView = UIStackView()
    let quickButtonStackView = UIStackView()
    
    let translationLabel = UILabel(text: "Translation")
    let nativeLabel = UILabel(text: "Native")
    let dividerLine = UIView()
    
    let relationshipButton = UIButton(type: .system)
    let tagButton = UIButton(type: .system)
    let favoriteButton = UIButton(type: .system)
    let noteButton = UIButton(type: .system)
    
    var quickButtons: [UIButton] {
        [relationshipButton, tagButton, favoriteButton, noteButton]
    }
    
    private(set) var style: Style = .regular
    
    /// A subscription for note card's `objectWillChange`.
    private var subscription: AnyCancellable?
    
    
    // MARK: Constraints
    
    var regularStyleConstraints: [NSLayoutConstraint] = []
    var shortStyleConstraints: [NSLayoutConstraint] = []
 
    
    // MARK: Method
    
    override func reload(with object: NoteCard) {
        super.reload(with: object)
        
        translationLabel.text = object.translation
        
        nativeLabel.text = object.native
        
        dividerLine.backgroundColor = object.formality.uiColor
        
        let imageName = object.isFavorited ? "star.fill" : "star"
        favoriteButton.setImage(createQuickButtonImage(systemName: imageName), for: .normal)
        
        noteButton.isUserInteractionEnabled = !object.note.isEmpty
        noteButton.tintColor = object.note.isEmpty ? .quaternaryLabel : .secondaryLabel
        
        relationshipButton.isUserInteractionEnabled = !object.relationships.isEmpty
        relationshipButton.tintColor = object.relationships.isEmpty ? .quaternaryLabel : .secondaryLabel
        
        tagButton.isUserInteractionEnabled = !object.tags.isEmpty
        tagButton.tintColor = object.tags.isEmpty ? .quaternaryLabel : .secondaryLabel
        
        setupSubscription()
    }
    
    private func setupSubscription() {
        subscription = object?
            .objectWillChange
            .eraseToAnyPublisher()
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] a in
                guard let self = self else { return }
                guard let object = self.object else { return }
                guard object.managedObjectContext != nil else { return }
                self.reload(with: object)
            })
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
        contentView.layer.borderColor = UIColor.appAccent.cgColor
        contentView.layer.borderWidth = show ? 3 : 0
    }
    
    func disableCell(_ disabled: Bool) {
        isUserInteractionEnabled = disabled ? false : true
        contentView.layer.opacity = disabled ? 0.4 : 1
    }
    
    @objc private func handleQuickButtonTapped(_ sender: UIButton) {
        guard let noteCard = object else { return }
        let type: QuickButtonType
        switch sender {
        case relationshipButton: type = .relationship
        case tagButton: type = .tag
        case favoriteButton: type = .favorite
        case noteButton: type = .note
        default: fatalError("🧨 handleQuickButtonTapped unknown button type 💣")
        }
        
        onQuickButtonTapped?(type, noteCard)
    }
    
    override func initCell() {
        super.initCell()
        setCellStyle(style)
    }
    
    override func setupCell() {
        super.setupCell()
        
        backgroundColor = UIColor(named: "note-card-background")
        layer.masksToBounds = false
        layer.cornerRadius = 15
        layer.shadowColor = UIColor.label.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 1
        layer.shadowOffset = .init(width: -1, height: 1)
        
        nativeLabel.font = .preferredFont(forTextStyle: .title3)
        
        translationLabel.font = .preferredFont(forTextStyle: .body)
        
        dividerLine.backgroundColor = NoteCard.Formality.unspecified.uiColor
        
        relationshipButton.setImage(createQuickButtonImage(systemName: "square.on.square"), for: .normal)
        tagButton.setImage(createQuickButtonImage(systemName: "tag"), for: .normal)
        favoriteButton.setImage(createQuickButtonImage(systemName: "star"), for: .normal)
        noteButton.setImage(createQuickButtonImage(systemName: "doc.plaintext"), for: .normal)
        
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
        
        quickButtonStackView.axis = .horizontal
        quickButtonStackView.spacing = 0
        quickButtonStackView.distribution = .fillEqually
        quickButtonStackView.addArrangedSubviews(relationshipButton, tagButton, favoriteButton, noteButton)
        
        let sharedConstraints = [
            labelStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            labelStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -16 * 2),
            labelStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            dividerLine.heightAnchor.constraint(equalToConstant: 1)
        ]
        
        regularStyleConstraints = sharedConstraints + [
            quickButtonStackView.topAnchor.constraint(equalTo: labelStackView.bottomAnchor, constant: 12),
            quickButtonStackView.heightAnchor.constraint(equalToConstant: 35),
            quickButtonStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            quickButtonStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            quickButtonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ]
        
        shortStyleConstraints = sharedConstraints + [
            labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ]
    }
    
    private func createQuickButtonImage(systemName: String) -> UIImage? {
        UIImage(systemName: systemName)?
            .applyingSymbolConfiguration(.init(scale: .medium))
    }
}


extension NoteCardCell {
    
    enum Style {
        case regular
        case short
        
        var height: CGFloat {
            switch self {
            case .regular: return 135
            case .short: return 100
            }
        }
    }
    
    enum QuickButtonType {
        case relationship
        case tag
        case favorite
        case note
    }
    
    enum ContextMenu {
        case delete
        
        var title: String {
            switch self {
            case .delete: return "Delete"
            }
        }
        
        var image: UIImage {
            switch self {
            case .delete: return UIImage(systemName: "trash")!
            }
        }
    }
}
