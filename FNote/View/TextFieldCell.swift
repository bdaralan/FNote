//
//  TextFieldCell.swift
//  FNote
//
//  Created by Dara Beng on 3/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


@objc protocol TextFieldCellDelegate: AnyObject {
    
    func textFieldCellDidEndEditing(_ cell: TextFieldCell, text: String)
    
    @objc optional func textFieldCell(_ cell: TextFieldCell, replacementTextFor overMaxCharacterCountText: String) -> String
}


class TextFieldCell: UITableViewCell, UITextFieldDelegate {
    
    weak var delegate: TextFieldCellDelegate?
    
    var maxCharacterCount = Int.max
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.returnKeyType = .done
        return tf
    }()
    
    var allowsEditing = false {
        didSet { textField.isEnabled = allowsEditing }
    }
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setupCell()
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
    
    func setDetail(text: String) {
        detailTextLabel?.text = text
    }
    
    func beginEditing() {
        textField.becomeFirstResponder()
    }
    
    @objc private func textFieldTextChanged(_ sender: UITextField) {
        let text = sender.text ?? ""
        if text.count > maxCharacterCount, let replacement = delegate?.textFieldCell?(self, replacementTextFor: text) {
            textField.text = replacement
        }
    }
}


extension TextFieldCell {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return allowsEditing
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textFieldCellDidEndEditing(self, text: textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }
}


extension TextFieldCell {
    
    private func setupCell() {
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldTextChanged), for: .editingChanged)
        
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
