//
//  VocabularyNoteCell.swift
//  FNote
//
//  Created by Dara Beng on 1/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit

class VocabularyNoteCell: UITableViewCell {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.preferredFont(forTextStyle: .body)
        return tv
    }()
    
    private let placeholderLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .lightGray
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    func reloadCell(text: String, placeholder: String) {
        textView.text = text
        placeholderLabel.text = placeholder
        hidePlaceholderIfNeeded()
    }
    
    func hidePlaceholderIfNeeded() {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    @objc private func dismissTextView() {
        textView.resignFirstResponder()
    }
}


extension VocabularyNoteCell {
    
    private func setupCell() {
        selectionStyle = .none
        contentView.addSubviews([textView, placeholderLabel])
        
        let safeArea = contentView.safeAreaLayoutGuide
        let margin: CGFloat = 20
        let padding: CGFloat = 8
        let constraints = [
            textView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: margin),
            textView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -margin),
            textView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: padding),
            textView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -padding),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 4),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        setupTextViewInputAccessoryView()
    }
    
    private func setupTextViewInputAccessoryView() {
        let toolBar = UIToolbar(frame: .init(x: 0, y: 0, width: 45, height: 45))
        let dismiss = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissTextView))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [space, dismiss]
        textView.inputAccessoryView = toolBar
    }
}
