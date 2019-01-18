//
//  VocabularyCollectionViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class VocabularyCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private lazy var cellSize: CGSize = {
        let padding = flowLayout.minimumLineSpacing * 2
        let width = collectionView.frame.width - padding
        let height = VocabularyCollectionCell.defaultHeight
        return CGSize(width: width, height: height)
    }()
    
    private var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }

    convenience init() {
        let layout = UICollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
        flowLayout = layout
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueRegisteredCell(VocabularyCollectionCell.self, for: indexPath)
        return cell
    }
}


extension VocabularyCollectionViewController {
    
    private func setupController() {
        collectionView.registerCell(VocabularyCollectionCell.self)
        collectionView.backgroundColor = UIColor(white: 0.96, alpha: 1)
        flowLayout.minimumLineSpacing = 20
        flowLayout.sectionInset.top = flowLayout.minimumLineSpacing
        flowLayout.sectionInset.bottom = flowLayout.minimumLineSpacing
    }
}
