//
//  TextFieldInputView.swift
//  FNote
//
//  Created by Dara Beng on 3/21/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class TextFieldInputView: UIView {
    
    let textField = UITextField()
    
    let label = UILabel()
    
    private let stack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideLabel(_ hide: Bool) {
        if hide {
            stack.removeArrangedSubview(label)
        } else {
            stack.addArrangedSubview(label)
        }
    }
    
    private func setupView() {
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 4
        stack.alignment = .leading
        
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        
        stack.addArrangedSubviews(textField, label)
        addSubviews(stack, useAutoLayout: true)
        NSLayoutConstraint.activateConstraints(
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        )
    }
}
