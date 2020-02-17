//
//  OnboardViewController.swift
//  FNote
//
//  Created by Dara Beng on 2/17/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class OnboardViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let viewModel: OnboardCollectionViewModel
    
    private var preloadImages: [String: UIImage] = [:]
    
    init(viewModel: OnboardCollectionViewModel) {
        self.viewModel = viewModel
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.sectionInsetReference = .fromSafeArea
        
        super.init(collectionViewLayout: layout)
        
        collectionView.registerCell(OnboardCell.self)
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.layer.masksToBounds = false
        
        for page in viewModel.pages {
            preloadImages[page.imageName] = UIImage(named: page.imageName)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let contentInset = collectionView.contentInset
        let contentSize = collectionView.bounds.size
        let height = contentSize.height - contentInset.top - contentInset.bottom
        let width = contentSize.width - contentInset.left - contentInset.right
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(OnboardCell.self, for: indexPath)
        let page = viewModel.pages[indexPath.row]
        cell.reload(with: page)
        
        DispatchQueue.main.async {
            cell.imageView.image = self.preloadImages[page.imageName]
        }
        
        return cell
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        viewModel.currentPage = Int(collectionView.contentOffset.x / collectionView.bounds.width)
        if viewModel.currentPage == viewModel.pages.count - 1 {
            viewModel.hasLastPageShown = true
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let x: CGFloat = collectionView.frame.width * CGFloat(viewModel.currentPage)
        return CGPoint(x: x, y: 0)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
}
