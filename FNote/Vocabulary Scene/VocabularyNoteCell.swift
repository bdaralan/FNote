//
//  VocabularyNoteCell.swift
//  FNote
//
//  Created by Dara Beng on 1/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


class VocabularyNoteCell: UITableViewCell, UITextViewDelegate {
    
    var noteChangedHandler: ((_ note: String) -> Void)?
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.preferredFont(forTextStyle: .body)
        return tv
    }()
    
    private let placeholderLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .lightGray
        lbl.text = ". . ."
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        textView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        noteChangedHandler?(textView.text)
        hidePlaceHolderIfNeeded()
    }
    
    func reloadCell(note: String) {
        textView.text = note
        hidePlaceHolderIfNeeded()
    }
    
    func setPlaceholder(_ placeholder: String) {
        placeholderLabel.text = placeholder
    }
    
    private func hidePlaceHolderIfNeeded() {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}


extension VocabularyNoteCell {
    
    private func setupCell() {
        selectionStyle = .none
        contentView.addSubviews(textView, placeholderLabel)
        
        let safeArea = contentView.safeAreaLayoutGuide
        let margin: CGFloat = 20
        let padding: CGFloat = 8
        NSLayoutConstraint.activate(
            textView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: margin),
            textView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -margin),
            textView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: padding),
            textView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -padding),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 4),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor)
        )
        
        setupTextViewInputAccessoryView()
    }
    
    /// Add a **Done** button to the accessory view if the device is an iPhone.
    private func setupTextViewInputAccessoryView() {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        let toolBar = UIToolbar(frame: .init(x: 0, y: 0, width: 45, height: 45))
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [space, done]
        textView.inputAccessoryView = toolBar
    }
    
    @objc private func doneButtonTapped() {
        textView.resignFirstResponder()
    }
}
