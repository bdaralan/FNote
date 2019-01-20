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
    
    #warning("sample data")
    private let vocabularies: [Vocabulary] = {
        var vocabs = [Vocabulary]()
        for i in 0...20 {
            let vocab = Vocabulary()
            vocab.isFavorited = Double(i).remainder(dividingBy: 2) == 0
            vocab.relations = Array(repeating: Vocabulary(), count: i * 2)
            vocab.alternatives = Array(repeating: Vocabulary(), count: i + 2)
            vocabs.append(vocab)
        }
        return vocabs
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setupNavItem()
    }

    convenience init() {
        let layout = VocabularyCollectionViewFlowLayout()
        self.init(collectionViewLayout: layout)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let layout = collectionViewLayout as! VocabularyCollectionViewFlowLayout
        layout.computeItemSize(newBounds: size)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc private func addVocabularyButtonTapped() {
        #warning("need to implement")
        print("addVocabularyButtonTapped")
        let vocabVC = VocabularyViewController(vocabulary: nil)
        vocabVC.delegate = self
        vocabVC.navigationItem.title = "Add Vocabulary"
        let navController = UINavigationController(rootViewController: vocabVC)
        present(navController, animated: true, completion: nil)
    }
}


// MARK: - Collection View Data Source and Delegate

extension VocabularyCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vocabularies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueRegisteredCell(VocabularyCollectionCell.self, for: indexPath)
        cell.delegate = self
        cell.reloadCell(with: vocabularies[indexPath.row])
        return cell
    }
}


extension VocabularyCollectionViewController: VocabularyCollectionCellDelegate {
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapFavoriteButton button: UIButton) {
        let vocabIndex = collectionView.indexPath(for: cell)!.row
        let vocab = vocabularies[vocabIndex]
        vocab.isFavorited.toggle()
        cell.reloadCell(with: vocab)
    }
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapRelationButton button: UIButton) {
        let vocabIndex = collectionView.indexPath(for: cell)!.row
        let vocab = vocabularies[vocabIndex]
        print(vocab.relations.count)
    }
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapAlternativeButton button: UIButton) {
        let vocabIndex = collectionView.indexPath(for: cell)!.row
        let vocab = vocabularies[vocabIndex]
        print(vocab.alternatives.count)
    }
}


extension VocabularyCollectionViewController: VocabularyViewControllerDelegate {
    
    func vocabularyViewController(_ viewController: VocabularyViewController, didRequestCancel vocabulary: Vocabulary) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func vocabularyViewController(_ viewController: VocabularyViewController, didRequestSave vocabulary: Vocabulary) {
        viewController.dismiss(animated: true, completion: nil)
    }
}


extension VocabularyCollectionViewController {
    
    private func setupController() {
        collectionView.registerCell(VocabularyCollectionCell.self)
        collectionView.backgroundColor = .offWhiteBackground
    }
    
    private func setupNavItem() {
        let addVocab = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addVocabularyButtonTapped))
        navigationItem.rightBarButtonItems = [addVocab]
    }
}
