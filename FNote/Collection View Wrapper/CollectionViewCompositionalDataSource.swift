//
//  CollectionViewCompositionalDataSource.swift
//  FNote
//
//  Created by Dara Beng on 1/19/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


protocol CollectionViewCompositionalDataSource {
    
    associatedtype DataSourceSection: Hashable
    associatedtype DataSourceItem: Hashable
    
    typealias Snapshot = NSDiffableDataSourceSnapshot<DataSourceSection, DataSourceItem>
    typealias DiffableDataSource = UICollectionViewDiffableDataSource<DataSourceSection, DataSourceItem>
    
    var dataSource: DiffableDataSource! { set get }
    
    func setupDataSource(with collectionView: UICollectionView)
    
    func updateSnapshot(animated: Bool, completion: (() -> Void)?)
}
