//
//  UserProfileHeaderView.swift
//  FNote
//
//  Created by Dara Beng on 3/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


class UserProfileHeaderView: UIView {
    
    let profile: UIImageView = {
        let iv = UIImageView(image: .userProfilePlaceholder)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        lbl.text = "Username"
        return lbl
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        profile.layer.cornerRadius = profile.bounds.height / 2
    }
    
    
    private func setupView() {
        addSubviews(profile, usernameLabel)
        
        let safeArea = safeAreaLayoutGuide
        NSLayoutConstraint.activate(
            profile.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            profile.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            profile.widthAnchor.constraint(equalTo: profile.heightAnchor),
            profile.heightAnchor.constraint(equalToConstant: 75),
            
            usernameLabel.topAnchor.constraint(equalTo: profile.bottomAnchor),
            usernameLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
        )
    }
}
