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
    
    weak var coordinator: (VocabularyViewer & VocabularyAdder & VocabularyRemover & UserProfileViewer)?
    
    private(set) var collection: VocabularyCollection?
    private(set) var fetchController: NSFetchedResultsController<Vocabulary>?
    
    private var guideView: DescriptionGuideView?
    private lazy var guide = UserGuide.load(resource: "add-new-vocabulary-collection")
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItems?.forEach({ $0.isEnabled = collection != nil })
        guard collection == nil else { return }
        setupGuideViewIfNeeded()
        guideView?.show(in: view)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let layout = collectionViewLayout as! VocabularyCollectionViewFlowLayout
        layout.computeItemSize(newBounds: size)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func configureFetchController() {
        guard let collection = collection, let context = collection.managedObjectContext else {
            self.collection = nil
            fetchController = nil
            return
        }
        let request: NSFetchRequest<Vocabulary> = Vocabulary.fetchRequest()
        request.predicate = NSPredicate(format: "collection == %@", collection)
        request.sortDescriptors = [NSSortDescriptor(key: "translation", ascending: true)]
        fetchController = NSFetchedResultsController<Vocabulary>(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        do {
            try fetchController?.performFetch()
            fetchController?.delegate = self
        } catch {
            print("failed to fetch vocabulary with error: \(error)")
        }
    }
    
    func setCollection(_ collection: VocabularyCollection?) {
        self.collection = collection
        if collection == nil {
            guideView?.show(in: view)
        } else {
            guideView?.remove()
        }
        configureFetchController()
        navigationItem.title = collection?.name ?? "Let's Get Started"
        collectionView.reloadData()
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
        case .insert: collectionView.insertItems(at: [newIndexPath!])
        case .update: collectionView.reloadItems(at: [indexPath!])
        case .delete: collectionView.deleteItems(at: [indexPath!])
        case .move: collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        }
    }
}


extension VocabularyCollectionViewController: VocabularyCollectionCellDelegate {
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapFavoriteButton button: UIButton) {
        guard let indexPath = collectionView.indexPath(for: cell), let vocabulary = fetchController?.object(at: indexPath) else { return }
        vocabulary.managedObjectContext?.perform {
            vocabulary.isFavorited.toggle()
            cell.reloadCell(with: vocabulary)
            vocabulary.managedObjectContext?.quickSave()
        }
    }
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapRelationButton button: UIButton) {
        guard let indexPath = collectionView.indexPath(for: cell), let vocabulary = fetchController?.object(at: indexPath) else { return }
        print(vocabulary.relations.count)
    }
    
    func vocabularyCollectionCell(_ cell: VocabularyCollectionCell, didTapAlternativeButton button: UIButton) {
        guard let indexPath = collectionView.indexPath(for: cell), let vocabulary = fetchController?.object(at: indexPath) else { return }
        print(vocabulary.alternatives.count)
    }
    
    func vocabularyCollectionCellDidBeginLongPress(_ cell: VocabularyCollectionCell) {
        guard let indexPath = collectionView.indexPath(for: cell), let collection = collection, let vocabulary = fetchController?.object(at: indexPath) else { return }
        coordinator?.removeVocabulary(vocabulary, from: collection, vc: self)
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
    
    @objc private func userProfileButtonTapped() {
        coordinator?.viewUserProfile()
    }
    
    @objc private func addVocabularyButtonTapped() {
        guard let collection = collection else { return }
        coordinator?.addNewVocabulary(to: collection)
    }
    
    private func setupGuideViewIfNeeded() {
        guard guideView == nil else { return }
        guideView = DescriptionGuideView()
        guideView?.guideTitle.text = guide?.title
        guideView?.guideDescription.text = guide?.description
        guideView?.imageView.image = UIImage(named: guide?.image ?? "")?.withRenderingMode(.alwaysTemplate)
        guideView?.imageView.tintColor = .darkGray
    }
}
