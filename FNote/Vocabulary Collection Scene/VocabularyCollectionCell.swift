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


class VocabularyCollectionCell: UICollectionViewCell, SizeClassable {
    
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
    
    let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.more, for: .normal)
        button.tintColor = .vocabularyAttributeTint
        return button
    }()
    
    let attributeView = VocabularyAttributeView()
    
    let seperatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let highlightView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    var currentSizeClassConstraints: [NSLayoutConstraint] = []
    
    let defaultHighlightColor = UIColor(colorHex: "DBFF98")
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        setupConstraints()
        setupTappedActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        NSLayoutConstraint.deactivate(currentSizeClassConstraints)
        currentSizeClassConstraints = configureSizeClassConstraints(for: traitCollection, interfaceIdiom: UIDevice.current.userInterfaceIdiom)
        NSLayoutConstraint.activate(currentSizeClassConstraints)
    }
    
    
    func reloadCell(with vocabulary: Vocabulary) {
        nativeLabel.text = vocabulary.native.isEmpty ? " " : vocabulary.native
        translationLabel.text = vocabulary.translation.isEmpty ? " " : vocabulary.translation
        attributeView.update(with: vocabulary)
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
    
    @objc private func buttonTapped(_ sender: UIButton) {
        delegate?.vocabularyCollectionCell(self, didTapButton: sender)
    }
    
    @objc private func attributeLabelTapped(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        let correspondingButton: UIButton
        switch label {
        case attributeView.tagView.label:
            correspondingButton = attributeView.tagView.button
        case attributeView.connectionView.label:
            correspondingButton = attributeView.connectionView.button
        case attributeView.politenessView.label:
            correspondingButton = attributeView.politenessView.button
        default: return
        }
        delegate?.vocabularyCollectionCell(self, didTapButton: correspondingButton)
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
        contentView.addSubviews(highlightView, seperatorLine, translationLabel, nativeLabel, moreButton, attributeView)
        
        let margin: CGFloat = 16
        let safeArea = contentView.safeAreaLayoutGuide
        NSLayoutConstraint.activate(
            highlightView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            highlightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            highlightView.topAnchor.constraint(equalTo: contentView.topAnchor),
            highlightView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            moreButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -margin),
            moreButton.centerYAnchor.constraint(equalTo: nativeLabel.centerYAnchor),
            moreButton.heightAnchor.constraint(equalToConstant: 30),
            moreButton.widthAnchor.constraint(equalTo: moreButton.heightAnchor),
            
            nativeLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: margin),
            nativeLabel.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -8),
            nativeLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            
            seperatorLine.topAnchor.constraint(equalTo: nativeLabel.bottomAnchor, constant: 8), // 4
            seperatorLine.leadingAnchor.constraint(equalTo: nativeLabel.leadingAnchor),
            seperatorLine.trailingAnchor.constraint(equalTo: moreButton.trailingAnchor),
            seperatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            translationLabel.topAnchor.constraint(equalTo: seperatorLine.bottomAnchor, constant: 8),
            translationLabel.leadingAnchor.constraint(equalTo: nativeLabel.leadingAnchor),
            translationLabel.trailingAnchor.constraint(equalTo: nativeLabel.trailingAnchor),
            
            attributeView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            attributeView.heightAnchor.constraint(equalToConstant: 30)
        )
        
        currentSizeClassConstraints = configureSizeClassConstraints(for: traitCollection, interfaceIdiom: UIDevice.current.userInterfaceIdiom)
        NSLayoutConstraint.activate(currentSizeClassConstraints)
    }
    
    func configureSizeClassConstraints(for trait: UITraitCollection, interfaceIdiom: UIUserInterfaceIdiom) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        let safeArea = contentView.safeAreaLayoutGuide
        let margin: CGFloat = 16
        
        switch interfaceIdiom {
        case .pad where traitCollection.horizontalSizeClass == .compact, .phone:
            constraints = [
                attributeView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: margin),
                attributeView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -margin)
            ]
        case .pad where traitCollection.horizontalSizeClass == .regular:
            constraints = [
                attributeView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                attributeView.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.75)
            ]
        default: break
        }
        
        return constraints
    }
    
    private func setupTappedActions() {
        moreButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        attributeView.allButtons.forEach({ $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside) })
        
        attributeView.allLabels.forEach { (label) in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(attributeLabelTapped))
            label.addGestureRecognizer(tapGesture)
            label.isUserInteractionEnabled = true
        }
    }
}
