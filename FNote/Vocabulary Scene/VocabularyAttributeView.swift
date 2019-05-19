//
//  VocabularyAttributeViewVocabularyAttributeView.swift
//  FNote
//
//  Created by Dara Beng on 5/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol VocabularyAttributeViewDelegate: AnyObject {
    
    func vocabularyAttributeView(_ control: VocabularyAttributeView, didTapButton button: UIButton)
}


class VocabularyAttributeView: UIView {
    
    weak var delegate: VocabularyAttributeViewDelegate?

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
    
    var attributeButtons: [UIButton] {
        return [tagView.button, connectionView.button, politenessView.button, favoriteButton]
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupControl()
        setupActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension VocabularyAttributeView {
    
    private func setupControl() {
        addSubviews([stackView, favoriteButton])
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
    
    private func setupActions() {
        attributeButtons.forEach({ $0.addTarget(self, action: #selector(attributeButtonTapped), for: .touchUpInside) })
    }
    
    @objc private func attributeButtonTapped(_ sender: UIButton) {
        delegate?.vocabularyAttributeView(self, didTapButton: sender)
    }
}
