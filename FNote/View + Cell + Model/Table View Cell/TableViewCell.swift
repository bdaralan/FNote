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
    
    private var stackLeadingAnchor: NSLayoutConstraint!
    private var stackTrailingAnchor: NSLayoutConstraint!
    private var stackTopAnchor: NSLayoutConstraint!
    private var stackBottomAnchor: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setStackViewInsets(_ insets: NSDirectionalEdgeInsets) {
        stackLeadingAnchor.constant = insets.leading
        stackTrailingAnchor.constant = -insets.trailing
        stackTopAnchor.constant = insets.top
        stackBottomAnchor.constant = -insets.bottom
        layoutIfNeeded()
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
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.addArrangedSubview(uiView)
        
        contentView.addSubviews(stackView, useAutoLayout: true)
        
        stackLeadingAnchor = stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        stackTrailingAnchor = stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        stackTopAnchor = stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        stackBottomAnchor = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        
        NSLayoutConstraint.activateConstraints(
            stackLeadingAnchor,
            stackTrailingAnchor,
            stackTopAnchor,
            stackBottomAnchor
        )
    }
}



