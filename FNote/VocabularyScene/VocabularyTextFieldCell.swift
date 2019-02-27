//
//  VocabularyTextFieldCell.swift
//  FNote
//
//  Created by Dara Beng on 1/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit

class VocabularyTextFieldCell: UITableViewCell {
    
    var isQuickCopyEnabled: Bool = true {
        didSet { longPressView.isHidden = !isQuickCopyEnabled }
    }
    
    var quickCopyCompletion: ((String) -> Void)?
    
    var longPressView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.preferredFont(forTextStyle: .title1)
        tf.contentVerticalAlignment = .top
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .done
        return tf
    }()
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .footnote)
        lbl.textColor = .gray
        return lbl
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        quickCopyCompletion = nil
    }
    
    
    func reloadCell(text: String, placeholder: String) {
        textField.text = text
        textField.placeholder = placeholder
        label.text = placeholder
    }
}


extension VocabularyTextFieldCell {
    
    private func setupCel() {
        selectionStyle = .none
        contentView.addSubviews([textField, label, longPressView])
        
        let safeArea = contentView.safeAreaLayoutGuide
        let margin: CGFloat = 16
        let constraints = [
            textField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: margin),
            textField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -margin),
            textField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            
            label.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            label.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8),
            
            longPressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            longPressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            longPressView.topAnchor.constraint(equalTo: contentView.topAnchor),
            longPressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        setupLongPressViewGesture()
    }
    
    private func setupLongPressViewGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleContentViewLongPressed(_:)))
        longPress.minimumPressDuration = 1
        longPressView.addGestureRecognizer(longPress)
    }
    
    @objc private func handleContentViewLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard isQuickCopyEnabled, gesture.state == .began else { return }
        guard let text = textField.text, !text.isEmpty else { return }
        UIPasteboard.general.string = text
        quickCopyCompletion?(text)
    }
}
