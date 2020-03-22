//
//  TableViewCell.swift
//  FNote
//
//  Created by Dara Beng on 3/21/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class TableViewCell<View: UIView>: UITableViewCell {
    
    private(set) var uiView = View()
    
    let stackView = UIStackView()
    
    var onLayoutSubviews: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStackViewInsets(_ insets: NSDirectionalEdgeInsets) {
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = insets
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutSubviews?()
    }
    
    func setView(_ view: UIView) {
        stackView.removeArrangedSubview(uiView)
        stackView.addArrangedSubview(view)
    }
    
    private func setupCell() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.addArrangedSubview(uiView)
        
        contentView.addSubviews(stackView, useAutoLayout: true)
        
        NSLayoutConstraint.activateConstraints(
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        )
    }
}



