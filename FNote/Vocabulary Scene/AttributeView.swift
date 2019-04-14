//
//  AttributeView.swift
//  FNote
//
//  Created by Dara Beng on 4/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit

class AttributeView: UIView {
    
    let button: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = .black
        return btn
    }()
    
    let label: UILabel = {
        let lbl = UILabel()
        return lbl
    }()
    
    init(image: UIImage?, label: String?) {
        super.init(frame: .zero)
        button.setImage(image, for: .normal)
        self.label.text = label
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubviews([button, label])
        let safeArea = safeAreaLayoutGuide
        let constraints = [
            button.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            button.heightAnchor.constraint(equalTo: safeArea.heightAnchor),
            button.widthAnchor.constraint(equalTo: button.heightAnchor),
            
            label.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
