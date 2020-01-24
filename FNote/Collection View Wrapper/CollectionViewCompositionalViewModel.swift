//
//  CollectionViewCompositionalViewModel.swift
//  FNote
//
//  Created by Dara Beng on 1/24/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


protocol CollectionViewCompositionalViewModel {
    
    func setupCollectionView(_ collection: UICollectionView)
    
    func updateSnapshot(animated: Bool, completion: (() -> Void)?)
}
