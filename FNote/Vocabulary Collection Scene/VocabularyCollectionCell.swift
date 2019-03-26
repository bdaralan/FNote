//
//  VocabularyCollectionCell.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol VocabularyCollectionCellDelegate: AnyObject {
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapButton button: UIButton)
}


class VocabularyCollectionCell: UICollectionViewCell {
    
    weak var delegate: VocabularyCollectionCellDelegate?
    
    let nativeLabel: UILabel = {
        let lbl = UILabel()
        let font = UIFont.preferredFont(forTextStyle: .title1)
        lbl.font = font
        var traits = font.fontDescriptor.symbolicTraits
        traits.insert(.traitBold)
        guard let fontDescriptor = font.fontDescriptor.withSymbolicTraits(traits) else { return lbl }
        lbl.font = UIFont(descriptor: fontDescriptor, size: 0)
        return lbl
    }()
    
    let translationLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .title1)
        return lbl
    }()
    
    let favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(.favorite, for: .normal)
        return btn
    }()
    
    let relationButton: UIButton = createStackViewButton(image: .relation)
    let alternativeButton: UIButton = createStackViewButton(image: .alternative)
    let politenessButton: UIButton = createStackViewButton(image: .politeness)
    let deleteButton: UIButton = createStackViewButton(image: .trashCan)
    let tagButton: UIButton = createStackViewButton(image: .tag)
    
    var stackViewButtons: [UIButton] { // leading to trailing order
        return [politenessButton, tagButton, alternativeButton, relationButton, deleteButton]
    }
    
    let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 30
        stack.tintColor = .black
        return stack
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
    
    func reloadCell(with vocabulary: Vocabulary) {
        nativeLabel.text = vocabulary.native
        translationLabel.text = vocabulary.translation
        favoriteButton.tintColor = UIColor(named: "favorite-vocab-\(vocabulary.isFavorited ? "true" : "false")")
        relationButton.setTitle("\(vocabulary.relations.count)", for: .normal)
        alternativeButton.setTitle("\(vocabulary.alternatives.count)", for: .normal)
        politenessButton.setTitle(vocabulary.politeness.string, for: .normal)
        tagButton.setTitle("\(vocabulary.tags.count)", for: .normal)
    }
}


extension VocabularyCollectionCell {
    
    private func setupCell() {
        setupConstraints()
        setupButtonTapHandler()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 15
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowColor = UIColor.black.cgColor
    }
    
    private func setupConstraints() {
        contentView.addSubviews([politenessButton, translationLabel, nativeLabel, favoriteButton, buttonStackView, seperatorView])
        
        let margin: CGFloat = 16
        let safeArea = contentView.safeAreaLayoutGuide
        let constraints = [
            favoriteButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -margin),
            favoriteButton.centerYAnchor.constraint(equalTo: nativeLabel.centerYAnchor),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),
            favoriteButton.widthAnchor.constraint(equalTo: favoriteButton.heightAnchor),
            
            nativeLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: margin),
            nativeLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8),
            nativeLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            
            seperatorView.topAnchor.constraint(equalTo: nativeLabel.bottomAnchor, constant: 8), //4
            seperatorView.leadingAnchor.constraint(equalTo: nativeLabel.leadingAnchor),
            seperatorView.trailingAnchor.constraint(equalTo: favoriteButton.trailingAnchor),
            seperatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            translationLabel.topAnchor.constraint(equalTo: seperatorView.bottomAnchor, constant: 8),
            translationLabel.leadingAnchor.constraint(equalTo: nativeLabel.leadingAnchor),
            translationLabel.trailingAnchor.constraint(equalTo: nativeLabel.trailingAnchor),
            
            buttonStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            buttonStackView.trailingAnchor.constraint(equalTo: favoriteButton.trailingAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 30)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupButtonTapHandler() {
        let tapAction = #selector(buttonTapped(_:))
        favoriteButton.addTarget(self, action: tapAction, for: .touchUpInside)
        for button in stackViewButtons {
            buttonStackView.addArrangedSubview(button)
            button.addTarget(self, action: tapAction, for: .touchUpInside)
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        delegate?.vocabularyCollectionCell(self, didTapButton: sender)
    }
    
    private static func createStackViewButton(image: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.contentHorizontalAlignment = .trailing
        button.semanticContentAttribute = .forceRightToLeft
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        return button
    }
}
