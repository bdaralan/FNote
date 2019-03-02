//
//  VocabularyTextFieldCell.swift
//  FNote
//
//  Created by Dara Beng on 1/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit

class VocabularyTextFieldCell: UITableViewCell {
    
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
    
    
    func reloadCell(text: String, placeholder: String) {
        textField.text = text
        textField.placeholder = placeholder
        label.text = placeholder
    }
}


extension VocabularyTextFieldCell {
    
    private func setupCel() {
        selectionStyle = .none
        contentView.addSubviews([textField, label])
        let safeArea = contentView.safeAreaLayoutGuide
        let margin: CGFloat = 16
        let constraints = [
            textField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: margin),
            textField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -margin),
            textField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            
            label.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            label.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
