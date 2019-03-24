//
//  VocabularyTagCell.swift
//  FNote
//
//  Created by Dara Beng on 3/21/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


class VocabularyTagCell: UITableViewCell {

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.registerCell(VocabularyCollectionViewTagCell.self)
        collection.backgroundColor = .white
        collection.showsHorizontalScrollIndicator = false
        collection.alwaysBounceHorizontal = true
        return collection
    }()
    
    var collectionViewTappedHandler: (() -> Void)?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reload(with vocabulary: Vocabulary, dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate & UICollectionViewDelegateFlowLayout) {
        let isTagCountZero = vocabulary.tags.isEmpty
        textLabel?.text = isTagCountZero ? "Tags" : nil
        detailTextLabel?.text = vocabulary.tags.isEmpty ? "None" : nil
        collectionView.isHidden = isTagCountZero
        collectionView.dataSource = dataSourceDelegate
        collectionView.delegate = dataSourceDelegate
        collectionView.reloadData()
    }
}


extension VocabularyTagCell {
    
    private func setupCell() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(collectionViewTapped))
        collectionView.addGestureRecognizer(tap)
        imageView?.image = .tag
        
        contentView.addSubviews([collectionView])
        let safeArea = contentView.safeAreaLayoutGuide
        let constraints = [
            collectionView.leadingAnchor.constraint(equalTo: imageView!.trailingAnchor, constant: 15),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func collectionViewTapped() {
        collectionViewTappedHandler?()
    }
}
