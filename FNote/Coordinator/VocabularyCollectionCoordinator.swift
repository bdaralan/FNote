//
//  VocabularyCollectionCoordinator.swift
//  FNote
//
//  Created by Dara Beng on 2/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit
import CoreData


class VocabularyCollectionCoordinator: Coordinator {
    
    var children: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var vocabularyCollectionVC: VocabularyCollectionViewController!
    
    var collectionContext: NSManagedObjectContext? {
        return vocabularyCollectionVC.collection.managedObjectContext
    }
    
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
    
    func start() {
        #warning("TODO: set sample collection if last selected collection is nil")
        let collection = CoreDataStack.current.allVocabularyCollections().first!
        vocabularyCollectionVC = VocabularyCollectionViewController(collection: collection)
        vocabularyCollectionVC.coordinator = self
        vocabularyCollectionVC.navigationItem.title = collection.name
        navigationController.tabBarItem = UITabBarItem(title: "Collections", image: .tabBarVocabCollection, tag: 0)
        navigationController.pushViewController(vocabularyCollectionVC, animated: false)
    }
}


extension VocabularyCollectionCoordinator: VocabularyViewer {
    
    func viewVocabulary(_ vocabulary: Vocabulary) {
        let vocabularyVC = VocabularyViewController(mode: .view(vocabulary))
        vocabularyVC.coordinator = self
        vocabularyVC.navigationItem.title = "Vocabulary"
        vocabularyVC.completion = { [weak self] (action) in
            if action == .save {
                self?.collectionContext?.quickSave()
            }
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(vocabularyVC, animated: true)
    }
    
    func selectPoliteness(for viewController: VocabularyViewController, current: Vocabulary.Politeness) {
        guard let navController = viewController.navigationController else { return }
        let availableOptions = Vocabulary.Politeness.allCases
        let options = availableOptions.map({ OptionTableViewController.Option(name: $0.rawValue, isSelected: $0.rawValue == current.rawValue) })
        let optionVC = OptionTableViewController(options: options)
        optionVC.navigationItem.title = "Politeness"
        optionVC.selectCompletion = { (index) in
            viewController.setPoliteness(availableOptions[index])
            navController.popViewController(animated: true)
        }
        navController.pushViewController(optionVC, animated: true)
    }
}


extension VocabularyCollectionCoordinator: VocabularyAdder {
    
    func addNewVocabulary(to collection: VocabularyCollection) {
        let vocabularyVC = VocabularyViewController(mode: .create(collection))
        vocabularyVC.coordinator = self
        vocabularyVC.navigationItem.title = "Add Vocabulary"
        vocabularyVC.completion = { [weak self] (action) in
            if action == .save {
                self?.collectionContext?.quickSave()
            }
            vocabularyVC.dismiss(animated: true, completion: nil)
        }
        navigationController.present(vocabularyVC.withNavController(), animated: true, completion: nil)
    }
}


extension VocabularyCollectionCoordinator: VocabularyRemover {
    
    func removeVocabulary(_ vocabulary: Vocabulary, from collection: VocabularyCollection, vc: VocabularyCollectionViewController) {
        guard collection.vocabularies.contains(vocabulary) else { return }
        let alert = UIAlertController(title: "Delete Vocabulary", message: nil, preferredStyle: .actionSheet) 
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            collection.removeFromVocabularies(vocabulary)
            collection.managedObjectContext?.perform {
                collection.managedObjectContext?.delete(vocabulary)
                collection.managedObjectContext?.quickSave()
            }
        }
        alert.addAction(delete)
        alert.preferredAction = alert.actions.first
        navigationController.present(alert, animated: true, completion: nil)
    }
}
