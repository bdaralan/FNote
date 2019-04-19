//
//  VocabularyCollectionCell.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol VocabularyCollectionCellDelegate: AnyObject {
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapAttribute view: UIView)
}


class VocabularyCollectionCell: UICollectionViewCell {
    
    weak var delegate: VocabularyCollectionCellDelegate?
    
    let nativeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .title1)
        lbl.text = " "
        return lbl
    }()
    
    let translationLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .title1)
        lbl.text = " "
        return lbl
    }()
    
    let attributeStackView = UIStackView()
    let tagView = AttributeView(image: .tag, label: nil)
    let moreView = AttributeView(image: .more, label: nil)
    let favoriteView = AttributeView(image: .favorite, label: nil)
    let connectionView = AttributeView(image: .connection, label: nil)
    let politenessView = AttributeView(image: .politeness, label: nil)
    
    /// All vocabluary's attribute buttons.
    var allButtons: [UIButton] {
        return [favoriteView.button, politenessView.button, connectionView.button, tagView.button, favoriteView.button]
    }
    
    let seperatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let highlightView: UIView = {
        let view = UIView()
        return view
    }()
    
    let defaultHighlightColor = UIColor(colorHex: "DBFF98")
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        setupConstraints()
        setupAttributeStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func reloadCell(with vocabulary: Vocabulary) {
        nativeLabel.text = vocabulary.native.isEmpty ? " " : vocabulary.native
        translationLabel.text = vocabulary.translation.isEmpty ? " " : vocabulary.translation
        tagView.label.text = "\(vocabulary.tags.count)"
        connectionView.label.text = "\(vocabulary.connections.count)"
        politenessView.label.text = UIDevice.current.userInterfaceIdiom == .pad ? vocabulary.politeness.displayText : vocabulary.politeness.abbreviation
        favoriteView.button.tintColor = vocabulary.isFavorited ? .vocabularyFavoriteStarTrue : .vocabularyFavoriteStarFalse
        
        #warning("TESTCODE: remove this")
        setHighlight(Bool.random(), color: nil)
    }
    
    /// Set cell highlighted state and color.
    /// - parameters:
    ///   - highlighted: Set `true` to highlight the cell.
    ///   - color: The highlight color. Set `nil` to keep the current color.
    func setHighlight(_ highlighted: Bool, color: UIColor?) {
        highlightView.isHidden = !highlighted
        guard let color = color else { return }
        highlightView.backgroundColor = color
    }
    
    @objc private func buttonTapped(_ sender: AnyObject) {
        if let button = sender as? UIButton {
            delegate?.vocabularyCollectionCell(self, didTapAttribute: button)
        } else if let gesture = sender as? UITapGestureRecognizer, let label = gesture.view {
            delegate?.vocabularyCollectionCell(self, didTapAttribute: label)
        }
    }
}


extension VocabularyCollectionCell {
    
    private func setupCell() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 15
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowColor = UIColor.black.cgColor
        highlightView.layer.cornerRadius = contentView.layer.cornerRadius
        highlightView.backgroundColor = defaultHighlightColor
    }
    
    private func setupConstraints() {
        contentView.addSubviews([highlightView, translationLabel, nativeLabel, moreView, attributeStackView, seperatorLine])
        
        let margin: CGFloat = 16
        let safeArea = contentView.safeAreaLayoutGuide
        let constraints = [
            highlightView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            highlightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            highlightView.topAnchor.constraint(equalTo: contentView.topAnchor),
            highlightView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            moreView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -margin),
            moreView.centerYAnchor.constraint(equalTo: nativeLabel.centerYAnchor),
            moreView.heightAnchor.constraint(equalToConstant: 30),
            moreView.widthAnchor.constraint(equalTo: moreView.heightAnchor),
            
            nativeLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: margin),
            nativeLabel.trailingAnchor.constraint(equalTo: moreView.leadingAnchor, constant: -8),
            nativeLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            
            seperatorLine.topAnchor.constraint(equalTo: nativeLabel.bottomAnchor, constant: 8), // 4
            seperatorLine.leadingAnchor.constraint(equalTo: nativeLabel.leadingAnchor),
            seperatorLine.trailingAnchor.constraint(equalTo: moreView.trailingAnchor),
            seperatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            translationLabel.topAnchor.constraint(equalTo: seperatorLine.bottomAnchor, constant: 8),
            translationLabel.leadingAnchor.constraint(equalTo: nativeLabel.leadingAnchor),
            translationLabel.trailingAnchor.constraint(equalTo: nativeLabel.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        // stack view constraints
        attributeStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8).isActive = true
        attributeStackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        if UIDevice.current.userInterfaceIdiom == .pad {
            attributeStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            attributeStackView.widthAnchor.constraint(equalToConstant: 600).isActive = true
        } else {
            attributeStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
            attributeStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        }
    }
    
    private func setupAttributeStackView() {
        attributeStackView.distribution = .fillEqually
        attributeStackView.tintColor = .black
        
        let attributeTappedAction = #selector(buttonTapped(_:))
        moreView.button.addTarget(self, action: attributeTappedAction, for: .touchUpInside)
        
        // These view are in order that they will appear from leading to trailing
        for attributeView in [tagView, connectionView, politenessView, favoriteView] {
            attributeStackView.addArrangedSubview(attributeView)
            attributeView.button.addTarget(self, action: attributeTappedAction, for: .touchUpInside)
            let tapGesture = UITapGestureRecognizer(target: self, action: attributeTappedAction)
            attributeView.label.addGestureRecognizer(tapGesture)
            attributeView.label.isUserInteractionEnabled = true
        }
    }
}
