//
//  VocabularyViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit

class VocabularyViewController: UITabBarController {
    
    let vocabCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }
}


extension VocabularyViewController {
    
    private func setupController() {
        view.backgroundColor = .white
    }
}
