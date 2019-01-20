//
//  VocabularySelectionCell.swift
//  FNote
//
//  Created by Dara Beng on 1/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol VocabularySelectionCellDelegate: class {
    
    func vocabularySelectionCell(_ cell: VocabularySelectionCell, didToggleSwitcher switcher: UISwitch)
}


class VocabularySelectionCell: UITableViewCell {
    
    weak var delegate: VocabularySelectionCellDelegate?
    
    let switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = .black
        switcher.isHidden = true
        switcher.isOn = false
        return switcher
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
        selectionStyle = .default
        switcher.isOn = false
        switcher.isHidden = true
    }
    
    func reloadCell(text: String, detail: String, image: UIImage) {
        textLabel?.text = text
        detailTextLabel?.text = detail
        imageView?.image = image
    }
    
    func reloadCell(detail: String) {
        detailTextLabel?.text = detail
    }
    
    func showSwitcher(on: Bool) {
        selectionStyle = .none
        contentView.bringSubviewToFront(switcher)
        switcher.isHidden = false
        switcher.isOn = on
        setupSwitcherValueChangedHandler()
    }
    
    @objc private func switcherValueChanged() {
        delegate?.vocabularySelectionCell(self, didToggleSwitcher: switcher)
    }
}


extension VocabularySelectionCell {
    
    private func setupCell() {
        detailTextLabel?.textColor = .gray
        contentView.addSubviews([switcher])
        let safeArea = contentView.safeAreaLayoutGuide
        let constraints = [
            switcher.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -22),
            switcher.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            switcher.heightAnchor.constraint(equalToConstant: 31),
            switcher.widthAnchor.constraint(equalToConstant: 49)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupSwitcherValueChangedHandler() {
        switcher.addTarget(self, action: #selector(switcherValueChanged), for: .valueChanged)
    }
}
