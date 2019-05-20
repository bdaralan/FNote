//
//  VocabularyAttributeViewVocabularyAttributeView.swift
//  FNote
//
//  Created by Dara Beng on 5/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


class VocabularyAttributeView: UIView {

    let tagView = AttributeView(image: .tag, label: "?")
    let connectionView = AttributeView(image: .connection, label: "?")
    let politenessView = AttributeView(image: .politeness, label: "?")
    
    let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.favorite, for: .normal)
        return button
    }()
    
    /// A stack view that holds all the attribute views.
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 4
        stack.distribution = .fillEqually
        return stack
    }()
    
    /// All attribute buttons.
    var allButtons: [UIButton] {
        return [tagView.button, connectionView.button, politenessView.button, favoriteButton]
    }
    
    /// All attribute labels.
    var allLabels: [UILabel] {
        return [tagView.label, connectionView.label, politenessView.label]
    }
    
    private var politeness = Vocabulary.Politeness.undecided

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePolitenessText(with: politeness)
    }
    
    
    func update(with vocabulary: Vocabulary) {
        tagView.label.text = "\(vocabulary.tags.count)"
        connectionView.label.text = "\(vocabulary.connections.count)"
        favoriteButton.tintColor = vocabulary.isFavorited ? .vocabularyFavoriteStarTrue : .vocabularyFavoriteStarFalse
        updatePolitenessText(with: vocabulary.politeness)
    }
    
    private func updatePolitenessText(with politeness: Vocabulary.Politeness) {
        self.politeness = politeness
        let shouldUseAbbreviation = bounds.width < 475 // 475 is from iPad 12.9 inch simulator's 1/3 split view mode
        politenessView.label.text = shouldUseAbbreviation ? politeness.abbreviation : politeness.displayText
    }
}


extension VocabularyAttributeView {
    
    private func setupControl() {
        tintColor = .vocabularyAttributeTint
        addSubviews(stackView, favoriteButton)
        stackView.addArrangedSubview(tagView)
        stackView.addArrangedSubview(connectionView)
        stackView.addArrangedSubview(politenessView)
        
        let safeArea = safeAreaLayoutGuide
        NSLayoutConstraint.activate(
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            stackView.heightAnchor.constraint(equalTo: safeArea.heightAnchor),
            stackView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            
            favoriteButton.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: stackView.spacing),
            favoriteButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            favoriteButton.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            favoriteButton.widthAnchor.constraint(equalTo: stackView.heightAnchor),
            favoriteButton.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        )
    }
}
