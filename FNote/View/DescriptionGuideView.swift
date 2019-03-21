//
//  AddNewCollectionGuideView.swift
//  FNote
//
//  Created by Dara Beng on 3/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


class DescriptionGuideView: UIView, GuideView {
    
    var guide: UserGuide? {
        didSet { reload(with: guide) }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .darkGray
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
    
    
    private func reload(with guide: UserGuide?) {
        guideTitle.text = guide?.title ?? ""
        guideDescription.text = guide?.description ?? ""
        imageView.image = UIImage(named: guide?.image ?? "nil")?.withRenderingMode(.alwaysTemplate)
    }
    
    func show(in superview: UIView) {
        superview.addSubviews([self])
        let safeArea = superview.safeAreaLayoutGuide
        centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true
        widthAnchor.constraint(equalTo: safeArea.widthAnchor, constant: -40).isActive = true
        heightAnchor.constraint(equalTo: safeArea.heightAnchor, multiplier: 0.75).isActive = true
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
            guideTitle.heightAnchor.constraint(greaterThanOrEqualToConstant: 27), // height for preferred font
            
            guideDescription.topAnchor.constraint(equalTo: guideTitle.bottomAnchor, constant: 8),
            guideDescription.centerXAnchor.constraint(equalTo: guideTitle.centerXAnchor),
            guideDescription.widthAnchor.constraint(equalTo: safeArea.widthAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: guideTitle.centerXAnchor),
            imageView.topAnchor.constraint(greaterThanOrEqualTo: safeArea.topAnchor, constant: 20),
            imageView.bottomAnchor.constraint(equalTo: guideTitle.topAnchor, constant: -8),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 100),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
