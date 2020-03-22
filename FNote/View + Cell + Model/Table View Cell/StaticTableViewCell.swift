//
//  StaticTableViewCell.swift
//  FNote
//
//  Created by Dara Beng on 3/21/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class StaticTableViewCell: UITableViewCell {
    
    var onLayoutSubviews: (() -> Void)?
    
    private(set) var toggle: UISwitch?
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutSubviews?()
    }
    
    func useToggle(_ use: Bool) {
        guard use else {
            toggle?.removeFromSuperview()
            return
        }
        
        guard self.toggle == nil else { return }
        
        let toggle = UISwitch()
        self.toggle = toggle
        
        contentView.addSubviews(toggle, useAutoLayout: true)
        NSLayoutConstraint.activateConstraints(
            toggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        )
    }
}
