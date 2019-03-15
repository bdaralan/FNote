//
//  AddNewCollectionGuideView.swift
//  FNote
//
//  Created by Dara Beng on 3/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


class DescriptionGuideView: UIView, GuideView {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let guideTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .title2)
        lbl.textAlignment = .center
        lbl.numberOfLines = 1
        return lbl
    }()
    
    let guideDescription: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .body)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(in superview: UIView) {
        superview.addSubviews([self])
        let safeArea = superview.safeAreaLayoutGuide
        centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true
        widthAnchor.constraint(equalTo: safeArea.widthAnchor, constant: -40).isActive = true
        heightAnchor.constraint(equalTo: safeArea.heightAnchor).isActive = true
    }
    
    func remove() {
        self.removeFromSuperview()
    }
}


extension DescriptionGuideView {
    
    private func setupView() {
        addSubviews([imageView, guideTitle, guideDescription])
        let safeArea = safeAreaLayoutGuide
        let constraints = [
            guideTitle.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            guideTitle.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            guideTitle.widthAnchor.constraint(equalTo: safeArea.widthAnchor),
            
            guideDescription.topAnchor.constraint(equalTo: guideTitle.bottomAnchor, constant: 8),
            guideDescription.centerXAnchor.constraint(equalTo: guideTitle.centerXAnchor),
            guideDescription.widthAnchor.constraint(equalTo: safeArea.widthAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: guideTitle.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: guideTitle.topAnchor, constant: -8),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 100),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
