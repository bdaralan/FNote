//
//  VocabularyCollectionCoordinator.swift
//  FNote
//
//  Created by Dara Beng on 2/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


class VocabularyCollectionCoordinator: Coordinator, VocabularyViewer, VocabularyAdder {
    
    var children: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var vocabularyCollectionVC: VocabularyCollectionViewController!
    
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
    
    func start() {
        #warning("TODO: set sample collection if last selected collection is nil")
        let collection = CoreDataStack.current.lastSelectedCollection()!
        vocabularyCollectionVC = VocabularyCollectionViewController(collection: collection)
        vocabularyCollectionVC.coordinator = self
        vocabularyCollectionVC.navigationItem.title = collection.name
        navigationController.tabBarItem = UITabBarItem(title: "Collections", image: .tabBarVocabCollection, tag: 0)
        navigationController.pushViewController(vocabularyCollectionVC, animated: false)
    }
    
    func viewVocabulary(_ vocabulary: Vocabulary) {
        let vocabularyVC = VocabularyViewController(mode: .view(vocabulary))
        vocabularyVC.navigationItem.title = "Vocabulary"
        vocabularyVC.saveChangesHandler = { [weak self] (vocabulary) in
            vocabulary.managedObjectContext?.quickSave()
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(vocabularyVC, animated: true)
    }
    
    func addNewVocabulary(to collection: VocabularyCollection) {
        let vocabularyVC = VocabularyViewController(mode: .add(collection))
        vocabularyVC.navigationItem.title = "Add Vocabulary"

        vocabularyVC.cancelActionHandler = {
            vocabularyVC.dismiss(animated: true, completion: nil)
        }

        vocabularyVC.addVocabularyHandler = { (newVocabulary) in
            newVocabulary.managedObjectContext?.quickSave()
            vocabularyVC.dismiss(animated: true, completion: nil)
        }
        
        navigationController.present(vocabularyVC.withNavController(), animated: true, completion: nil)
    }
}
