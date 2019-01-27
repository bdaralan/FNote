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
    
    private var collection: VocabularyCollection
    private(set) var vocabularies: [Vocabulary] = []
    
    init(collection: VocabularyCollection) {
        self.collection = collection
        self.vocabularies = collection.vocabularies.sorted(by: { $0.translation < $1.translation })
        let layout = VocabularyCollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setupNavItem()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let layout = collectionViewLayout as! VocabularyCollectionViewFlowLayout
        layout.computeItemSize(newBounds: size)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func reloadCollection(_ collection: VocabularyCollection) {
        self.collection = collection
        self.vocabularies = collection.vocabularies.sorted(by: { $0.translation < $1.translation })
        collectionView.reloadData()
    }
    
    @objc private func addVocabularyButtonTapped() {
        #warning("need to implement")
        print("addVocabularyButtonTapped")
        let addVocabVC = VocabularyViewController(collection: collection)
        addVocabVC.delegate = self
        addVocabVC.navigationItem.title = "Add Vocabulary"
        let navController = UINavigationController(rootViewController: addVocabVC)
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
        vocab.managedObjectContext?.quickSave()
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
        vocabulary.managedObjectContext?.quickSave()
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func vocabularyViewController(_ viewController: VocabularyViewController, didRequestSave vocabulary: Vocabulary) {
        collection.managedObjectContext?.quickSave()
        vocabularies = collection.vocabularies.sorted(by: { $0.translation < $1.translation })
        collectionView.reloadData()
        viewController.dismiss(animated: true, completion: nil)
    }
}


extension VocabularyCollectionViewController {
    
    private func setupController() {
        collectionView.registerCell(VocabularyCollectionCell.self)
        collectionView.backgroundColor = .offWhiteBackground
        collectionView.alwaysBounceVertical = true
    }
    
    private func setupNavItem() {
        let addVocab = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addVocabularyButtonTapped))
        navigationItem.rightBarButtonItems = [addVocab]
    }
}
