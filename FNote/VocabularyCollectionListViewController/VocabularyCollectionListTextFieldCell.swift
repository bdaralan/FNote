//
//  VocabularyCollectionListTextFieldCell.swift
//  FNote
//
//  Created by Dara Beng on 3/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol VocabularyCollectionListTextFieldCellDelegate: AnyObject {
    
    func textFieldCellDidEndEditing(_ cell: VocabularyCollectionListTextFieldCell, text: String)
}


class VocabularyCollectionListTextFieldCell: UITableViewCell, UITextFieldDelegate {
    
    weak var delegate: VocabularyCollectionListTextFieldCellDelegate?
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.returnKeyType = .done
        return tf
    }()
    
    var allowsEditing: Bool = false {
        didSet { textField.isEnabled = allowsEditing }
    }
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupCell()
        textField.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTextField(text: String) {
        textField.text = text
    }
    
    func setTextField(placeholder: String) {
        textField.placeholder = placeholder
    }
    
    func beginEditing() {
        textField.becomeFirstResponder()
    }
}


extension VocabularyCollectionListTextFieldCell {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return allowsEditing
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        delegate?.textFieldCellDidEndEditing(self, text: textField.text ?? "")
    }
}


extension VocabularyCollectionListTextFieldCell {
    
    private func setupCell() {
        contentView.addSubviews([textField])
        let safeArea = contentView.safeAreaLayoutGuide
        let constraints = [
            textField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 15),
            textField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15),
            textField.topAnchor.constraint(equalTo: safeArea.topAnchor),
            textField.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
