//
//  VocabularyCollectionViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit
import CoreData


class VocabularyCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    weak var coordinator: (VocabularyViewer & VocabularyAdder & VocabularyRemover)?
    
    private(set) var collection: VocabularyCollection
    
    private(set) var fetchController: NSFetchedResultsController<Vocabulary>!
    
    init(collection: VocabularyCollection) {
        self.collection = collection
        let layout = VocabularyCollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
        configureFetchController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setupNavItems()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let layout = collectionViewLayout as! VocabularyCollectionViewFlowLayout
        layout.computeItemSize(newBounds: size)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc private func addVocabularyButtonTapped() {
        coordinator?.addNewVocabulary(to: collection)
    }
    
    private func configureFetchController() {
        let request: NSFetchRequest<Vocabulary> = Vocabulary.fetchRequest()
        request.predicate = NSPredicate(format: "collection == %@", collection)
        request.sortDescriptors = [NSSortDescriptor(key: "translation", ascending: true)]
        fetchController = NSFetchedResultsController<Vocabulary>(
            fetchRequest: request,
            managedObjectContext: collection.managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        do {
            try fetchController.performFetch()
            fetchController.delegate = self
        } catch {
            print("failed to fetch vocabulary with error: \(error)")
        }
    }
    
    func setCollection(_ collection: VocabularyCollection) {
        self.collection = collection
        configureFetchController()
        collectionView.reloadData()
    }
}


// MARK: - Collection View Data Source and Delegate

extension VocabularyCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchController.fetchedObjects?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueRegisteredCell(VocabularyCollectionCell.self, for: indexPath)
        cell.delegate = self
        cell.reloadCell(with: fetchController.object(at: indexPath))
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        coordinator?.viewVocabulary(fetchController.object(at: indexPath))
    }
}


extension VocabularyCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        case .move:
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        }
    }
}


extension VocabularyCollectionViewController: VocabularyCollectionCellDelegate {
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapFavoriteButton button: UIButton) {
        let indexPath = collectionView.indexPath(for: cell)!
        let vocabulary = fetchController.object(at: indexPath)
        vocabulary.managedObjectContext?.perform {
            vocabulary.isFavorited.toggle()
            cell.reloadCell(with: vocabulary)
            vocabulary.managedObjectContext?.quickSave()
        }
    }
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapRelationButton button: UIButton) {
        let vocabIndexPath = collectionView.indexPath(for: cell)!
        let vocabulary = fetchController.object(at: vocabIndexPath)
        print(vocabulary.relations.count)
    }
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapAlternativeButton button: UIButton) {
        let vocabIndexPath = collectionView.indexPath(for: cell)!
        let vocabulary = fetchController.object(at: vocabIndexPath)
        print(vocabulary.alternatives.count)
    }
    
    func vocabularyCollectionCellDidBeginLongPress(_ cell: VocabularyCollectionCell) {
        let indexPath = collectionView.indexPath(for: cell)!
//        collection.managedObjectContext?.delete(fetchController.object(at: indexPath))
//        collection.managedObjectContext?.quickSave()
        coordinator?.removeVocabulary(fetchController.object(at: indexPath), from: collection)
    }
}


extension VocabularyCollectionViewController {
    
    private func setupController() {
        collectionView.registerCell(VocabularyCollectionCell.self)
        collectionView.backgroundColor = .offWhiteBackground
        collectionView.alwaysBounceVertical = true
    }
    
    private func setupNavItems() {
        let addVocab = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addVocabularyButtonTapped))
        navigationItem.rightBarButtonItems = [addVocab]
    }
}
