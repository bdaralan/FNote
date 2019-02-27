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
    }
    
    
    func start() {
        #warning("TODO: set sample collection if last selected collection is nil")
        let collection = CoreDataStack.current.lastSelectedCollection()!
        vocabularyCollectionVC = VocabularyCollectionViewController(collection: collection)
        vocabularyCollectionVC.coordinator = self
        vocabularyCollectionVC.navigationItem.title = vocabularyCollectionVC.collection.name
        navigationController.tabBarItem = UITabBarItem(title: "Collections", image: .tabBarVocabCollection, tag: 0)
        navigationController.pushViewController(vocabularyCollectionVC, animated: false)
    }
    
    func viewVocabulary(_ vocabulary: Vocabulary) {
        print("viewVocabulary")
        let vc = VocabularyViewController(vocabulary: vocabulary, collection: vocabulary.collection)
        vc.navigationItem.title = "Vocabulary"
        
        vc.cancelActionHandler = {
            vc.setMode(.view)
            vc.view.endEditing(true)
        }
        
        vc.saveChangesHandler = { (vocabulary) in
            vocabulary.managedObjectContext?.quickSave()
            vc.setMode(.view)
            vc.view.endEditing(true)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addNewVocabulary(to collection: VocabularyCollection) {
        print("addVocabulary")
        let vc = VocabularyViewController(vocabulary: nil, collection: collection)
        vc.navigationItem.title = "Add Vocabulary"
        
        vc.cancelActionHandler = {
            vc.dismiss(animated: true, completion: nil)
        }
        
        vc.addVocabularyHandler = { (vocabulary, collection) in
            vocabulary.setCollection(collection)
            vocabulary.managedObjectContext?.quickSave()
            vc.dismiss(animated: true, completion: nil)
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navigationController.present(navController, animated: true, completion: nil)
    }
}
