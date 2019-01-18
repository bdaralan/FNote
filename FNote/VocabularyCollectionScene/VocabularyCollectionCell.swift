//
//  VocabularyCollectionCell.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol VocabularyCollectionCellDelegate: class {
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapFavoriteButton button: UIButton)
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapRelationButton button: UIButton)
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapAlternativeButton button: UIButton)
}


class VocabularyCollectionCell: UICollectionViewCell {
    
    weak var delegate: VocabularyCollectionCellDelegate?
    
    let originalLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .title1)
        return lbl
    }()
    
    let translationLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .title1)
        return lbl
    }()
    
    let formalityImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .red
        return view
    }()
    
    let favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(.favorite, for: .normal)
        return btn
    }()
    
    let relationButton: UIButton = .init(type: .system)
    let alternativeButton: UIButton = .init(type: .system)
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        formalityImageView.layer.cornerRadius = formalityImageView.frame.height / 2
    }
    
    func reloadCell(with vocab: Vocabulary) {
        originalLabel.text = vocab.original
        translationLabel.text = vocab.translation
        favoriteButton.tintColor = UIColor(named: "favorite-vocab-\(vocab.isFavorited ? "true" : "false")")
        relationButton.setTitle("\(vocab.relations.count)", for: .normal)
        alternativeButton.setTitle("\(vocab.alternatives.count)", for: .normal)
    }
}


extension VocabularyCollectionCell {
    
    private func setupCell() {
        setupConstraints()
        setupButtonStackView()
        setupButtonTapHandlers()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 15
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowColor = UIColor.black.cgColor
    }
    
    private func setupConstraints() {
        contentView.addSubviews([formalityImageView, translationLabel, originalLabel, favoriteButton, buttonStackView, seperatorView])
        
        let margin: CGFloat = 16
        let safeArea = contentView.safeAreaLayoutGuide
        let constraints = [
            formalityImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: margin),
            formalityImageView.centerYAnchor.constraint(equalTo: translationLabel.centerYAnchor),
            formalityImageView.heightAnchor.constraint(equalToConstant: 15),
            formalityImageView.widthAnchor.constraint(equalTo: formalityImageView.heightAnchor),
            
            favoriteButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -margin),
            favoriteButton.centerYAnchor.constraint(equalTo: translationLabel.centerYAnchor),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),
            favoriteButton.widthAnchor.constraint(equalTo: favoriteButton.heightAnchor),
            
            translationLabel.leadingAnchor.constraint(equalTo: formalityImageView.trailingAnchor, constant: 8),
            translationLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            
            seperatorView.topAnchor.constraint(equalTo: translationLabel.bottomAnchor, constant: 4),
            seperatorView.leadingAnchor.constraint(equalTo: formalityImageView.leadingAnchor),
            seperatorView.trailingAnchor.constraint(equalTo: favoriteButton.trailingAnchor),
            seperatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            originalLabel.topAnchor.constraint(equalTo: seperatorView.bottomAnchor, constant: 8),
            originalLabel.leadingAnchor.constraint(equalTo: formalityImageView.leadingAnchor),
            
            buttonStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            buttonStackView.trailingAnchor.constraint(equalTo: favoriteButton.trailingAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 30)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func favoriteButtonTapped() {
        delegate?.vocabularyCollectionCell(self, didTapFavoriteButton: favoriteButton)
    }
    
    @objc private func relationButtonTapped() {
        delegate?.vocabularyCollectionCell(self, didTapRelationButton: relationButton)
    }
    
    @objc private func alternativeButtonTapped() {
        delegate?.vocabularyCollectionCell(self, didTapAlternativeButton: alternativeButton)
    }
    
    private func setupButtonTapHandlers() {
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        relationButton.addTarget(self, action: #selector(relationButtonTapped), for: .touchUpInside)
        alternativeButton.addTarget(self, action: #selector(alternativeButtonTapped), for: .touchUpInside)
    }
    
    private func setupButtonStackView() {
        buttonStackView.addArrangedSubview(alternativeButton)
        buttonStackView.addArrangedSubview(relationButton)
        setupStackViewButton(alternativeButton, title: "99", image: .alternative)
        setupStackViewButton(relationButton, title: "99", image: .relation)
    }
    
    private func setupStackViewButton(_ button: UIButton, title: String, image: UIImage) {
        button.setTitle(title, for: .normal)
        button.setImage(image, for: .normal)
        button.contentHorizontalAlignment = .trailing
        button.semanticContentAttribute = .forceRightToLeft
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
    }
}
