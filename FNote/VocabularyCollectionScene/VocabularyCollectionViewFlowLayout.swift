//
//  VocabularyCollectionViewFlowLayout.swift
//  FNote
//
//  Created by Dara Beng on 1/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit

class VocabularyCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        let space: CGFloat = 20
        minimumLineSpacing = space
        sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        guard let size = collectionView?.bounds.size else { return }
        computeItemSize(newBounds: size)
    }
    
    func computeItemSize(newBounds: CGSize) {
        let sectionInsetWidth = sectionInset.left + sectionInset.right
        let width = newBounds.width - sectionInsetWidth
        itemSize = CGSize(width: width, height: 132)
    }
}
