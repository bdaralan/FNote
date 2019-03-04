//
//  VocabularyCollectionCoordinator.swift
//  FNote
//
//  Created by Dara Beng on 2/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit
import CoreData


class VocabularyCollectionCoordinator: Coordinator, VocabularyViewer, VocabularyAdder, VocabularyRemover {
    
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
        let collection = CoreDataStack.current.vocabularyCollections().first!
        vocabularyCollectionVC = VocabularyCollectionViewController(collection: collection)
        vocabularyCollectionVC.coordinator = self
        vocabularyCollectionVC.navigationItem.title = collection.name
        navigationController.tabBarItem = UITabBarItem(title: "Collections", image: .tabBarVocabCollection, tag: 0)
        navigationController.pushViewController(vocabularyCollectionVC, animated: false)
    }
    
    func viewVocabulary(_ vocabulary: Vocabulary) {
        let vocabularyVC = VocabularyViewController(mode: .view(vocabulary))
        vocabularyVC.coordinator = self
        vocabularyVC.navigationItem.title = "Vocabulary"
        vocabularyVC.saveCompletion = { [weak self] in
            self?.collectionContext?.quickSave()
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(vocabularyVC, animated: true)
    }
    
    func selectPoliteness(for vocabulary: Vocabulary, completion: @escaping (Vocabulary.Politeness) -> Void) {
        let options = Vocabulary.Politeness.allCases
        let optionVC = OptionTableViewController(options: options.map({ $0.string }), selectedOptions: [vocabulary.politeness])
        optionVC.navigationItem.title = "Politeness"
        optionVC.selectOptionHandler = { [weak self] (selectedIndex) in
            guard let self = self else { return }
            completion(options[selectedIndex])
            self.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(optionVC, animated: true)
    }
    
    func addNewVocabulary(to collection: VocabularyCollection) {
        let vocabularyVC = VocabularyViewController(mode: .add(collection))
        vocabularyVC.coordinator = self
        vocabularyVC.navigationItem.title = "Add Vocabulary"
        vocabularyVC.cancelCompletion = {
            vocabularyVC.dismiss(animated: true, completion: nil)
        }
        vocabularyVC.saveCompletion = { [weak self] in
            self?.collectionContext?.quickSave()
            vocabularyVC.dismiss(animated: true, completion: nil)
        }
        navigationController.present(vocabularyVC.withNavController(), animated: true, completion: nil)
    }
    
    func removeVocabulary(_ vocabulary: Vocabulary, from collection: VocabularyCollection) {
        guard collection.vocabularies.contains(vocabulary), let context = collection.managedObjectContext else { return }
        let alert = UIAlertController(title: "Delete Vocabulary", message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Delete", style: .destructive) { (action) in
            context.delete(vocabulary)
            context.quickSave()
        })
        alert.preferredAction = alert.actions.first
        navigationController.present(alert, animated: true, completion: nil)
    }
}
