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
    
    weak var coordinator: (VocabularyViewable & UserProfileViewable)?
    
    private(set) var collection: VocabularyCollection?
    private(set) var fetchController: NSFetchedResultsController<Vocabulary>?
    
    private lazy var guideView = DescriptionGuideView()
    private lazy var addVocabularyGuide = UserGuide.load(resource: .addVocabulary)
    private lazy var welcomeGuide = UserGuide.load(resource: .addCollection)
    
    
    init(collection: VocabularyCollection?) {
        super.init(collectionViewLayout: VocabularyCollectionViewFlowLayout())
        setCollection(collection)
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
    
    
    private func configureFetchController(collection: VocabularyCollection?) {
        guard let collection = collection, let context = collection.managedObjectContext else {
            fetchController = nil
            return
        }
        
        let request: NSFetchRequest<Vocabulary> = Vocabulary.fetchRequest()
        request.predicate = NSPredicate(format: "collection == %@", collection)
        request.sortDescriptors = [NSSortDescriptor(key: "translation", ascending: true)]
        fetchController = NSFetchedResultsController<Vocabulary>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchController?.performFetch()
            fetchController?.delegate = self
        } catch {
            fatalError("failed to fetch vocabulary with error: \(error)")
        }
    }
    
    func setCollection(_ collection: VocabularyCollection?) {
        if collection == nil {
            guideView.guide = welcomeGuide
            guideView.show(in: view)
        } else if collection?.vocabularies.isEmpty == true {
            guideView.guide = addVocabularyGuide
            guideView.show(in: view)
        } else {
            guideView.remove()
        }
        navigationItem.title = collection?.name ?? guideView.guide?.name
        navigationItem.rightBarButtonItems?.forEach({ $0.isEnabled = collection != nil })
        
        if self.collection == nil || self.collection != collection {
            configureFetchController(collection: collection)
            collectionView.reloadData()
        }
        self.collection = collection
    }
    
    private func cellFavoriteAttributeTapped(cell: VocabularyCollectionCell, indexPath: IndexPath) {
        guard let vocabulary = fetchController?.object(at: indexPath) else { return }
        vocabulary.managedObjectContext?.perform {
            vocabulary.isFavorited.toggle()
            cell.reloadCell(with: vocabulary)
            vocabulary.managedObjectContext?.quickSave()
        }
    }
    
    private func cellConnectionAttributeTapped(cell: VocabularyCollectionCell, indexPath: IndexPath) {
        #warning("TODO: implement")
        guard let vocabulary = fetchController?.object(at: indexPath) else { return }
        let vocabularyVC = VocabularyViewController(mode: .view(vocabulary))
        coordinator?.selectVocabularyConnection(for: vocabularyVC)
    }
    
    private func cellPolitenessAttributeTapped(cell: VocabularyCollectionCell, indexPath: IndexPath) {
        guard let vocabulary = fetchController?.object(at: indexPath) else { return }
        let vocabularyVC = VocabularyViewController(mode: .view(vocabulary))
        coordinator?.selectPoliteness(for: vocabularyVC, current: vocabulary.politeness)
    }
    
    private func cellMoreAttibuteTapped(cell: VocabularyCollectionCell, indexPath: IndexPath) {
        guard let collection = collection, let vocabulary = fetchController?.object(at: indexPath) else { return }
        coordinator?.selectMoreActions(for: vocabulary, in: collection, sender: cell.moreView)
    }
    
    private func cellTagAttributeTapped(cell: VocabularyCollectionCell, indexPath: IndexPath) {
        #warning("TODO: implement")
        guard let vocabulary = fetchController?.object(at: indexPath) else { return }
        let vocabularyVC = VocabularyViewController(mode: .view(vocabulary))
        coordinator?.selectTags(for: vocabularyVC, current: vocabularyVC.currentTags, existingTags: vocabularyVC.existingTags)
    }
    
    @objc private func userProfileButtonTapped() {
        coordinator?.viewUserProfile()
    }
    
    @objc private func addVocabularyButtonTapped() {
        guard let collection = collection else { return }
        coordinator?.addNewVocabulary(to: collection)
    }
}


// MARK: - Collection View Data Source and Delegate

extension VocabularyCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchController?.fetchedObjects?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueRegisteredCell(VocabularyCollectionCell.self, for: indexPath)
        guard let vocabulary = fetchController?.object(at: indexPath) else { return cell }
        cell.delegate = self
        cell.reloadCell(with: vocabulary)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vocabluary = fetchController?.object(at: indexPath) else { return }
        coordinator?.viewVocabulary(vocabluary)
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
            collectionView.reloadItems(at: [indexPath!, newIndexPath!])
        @unknown default: ()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if collection?.vocabularies.isEmpty == true {
            guideView.guide = addVocabularyGuide
            guideView.show(in: view)
        } else {
            guideView.remove()
        }
    }
}


extension VocabularyCollectionViewController: VocabularyCollectionCellDelegate {
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapAttribute view: UIView) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        switch view {
        case cell.favoriteView.button, cell.favoriteView.label:
            cellFavoriteAttributeTapped(cell: cell, indexPath: indexPath)
        case cell.connectionView.button, cell.connectionView.label:
            cellConnectionAttributeTapped(cell: cell, indexPath: indexPath)
        case cell.politenessView.button, cell.politenessView.label:
            cellPolitenessAttributeTapped(cell: cell, indexPath: indexPath)
        case cell.moreView.button, cell.moreView.label:
            cellMoreAttibuteTapped(cell: cell, indexPath: indexPath)
        case cell.tagView.button, cell.tagView.label:
            cellTagAttributeTapped(cell: cell, indexPath: indexPath)
        default: ()
        }
    }
}


extension VocabularyCollectionViewController {
    
    private func setupController() {
        collectionView.registerCell(VocabularyCollectionCell.self)
        collectionView.backgroundColor = .offWhiteBackground
        collectionView.alwaysBounceVertical = true
    }
    
    private func setupNavItems() {
        let userProfile = UIBarButtonItem(image: .profileNavImagePlaceholder, style: .plain, target: self, action: #selector(userProfileButtonTapped))
        let addVocab = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addVocabularyButtonTapped))
        navigationItem.leftBarButtonItem = userProfile
        navigationItem.rightBarButtonItems = [addVocab]
    }
}
