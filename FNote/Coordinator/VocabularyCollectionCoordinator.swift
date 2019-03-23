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
        return vocabularyCollectionVC.collection?.managedObjectContext
    }
    
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
    
    func start() {
        let coreData = CoreDataStack.current
        let recordName = UserDefaultsManager.selectedVocabularyCollectionRecordName ?? ""
        let collection = coreData.fetchVocabularyCollection(recordName: recordName, context: coreData.mainContext)
        vocabularyCollectionVC = VocabularyCollectionViewController(collection: collection)
        vocabularyCollectionVC.coordinator = self
        navigationController.tabBarItem = UITabBarItem(title: "Collection", image: .tabBarVocabCollection, tag: 0)
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
        let politenesses = Vocabulary.Politeness.allCases
        let options = politenesses.map({ OptionTableViewController.Option(name: $0.string, isSelected: $0 == current) })
        let optionVC = OptionTableViewController(selectMode: .single, options: options, title: "Politeness")
        
        if let navController = viewController.navigationController {
            optionVC.useNavCancelItem = false
            optionVC.selectCompletion = { (index) in
                viewController.setPoliteness(politenesses[index])
                navController.popViewController(animated: true)
            }
            optionVC.cancelCompletion = {
                navController.popViewController(animated: true)
            }
            navController.pushViewController(optionVC, animated: true)
            
        } else {
            let optionNavController = optionVC.withNavController()
            optionVC.selectCompletion = { (index) in
                viewController.completion = { [weak self] (result) in
                    guard result == .save else { return }
                    self?.collectionContext?.quickSave()
                }
                viewController.setPoliteness(politenesses[index])
                viewController.saveChanges()
                optionNavController.dismiss(animated: true, completion: nil)
            }
            optionVC.cancelCompletion = {
                optionNavController.dismiss(animated: true, completion: nil)
            }

            if UIDevice.current.userInterfaceIdiom == .pad {
                let width = UIScreen.main.bounds.width / 2
                let height = CGFloat(options.count) * optionVC.tableView.rowHeight + 70
                optionNavController.preferredContentSize = CGSize(width: width, height: height)
                optionNavController.modalPresentationStyle = .formSheet
            }
            navigationController.present(optionNavController, animated: true, completion: nil)
        }
    }
    
    func selectTags(for viewController: VocabularyViewController, current: [Tag]) {
        let allTags = CoreDataStack.current.user().tags.sorted(by: { $0.name < $1.name })
        let options = allTags.map({ OptionTableViewController.Option(name: $0.name, isSelected: current.contains($0)) })
        let optionVC = OptionTableViewController(selectMode: .multiple, options: options, title: "Tags")
        optionVC.allowAddNewOption = true
        
        if let navController = viewController.navigationController {
            optionVC.useNavCancelItem = false
            optionVC.selectCompletion = { (index) in
                print("selected \(options[index].name)")
            }
            optionVC.deselectCompletion = { (index) in
                print("deselected \(options[index].name)")
            }
            optionVC.doneCompletion = {
                print("done selected \(optionVC.options)")
                navController.popViewController(animated: true)
            }
            navController.pushViewController(optionVC, animated: true)
        }
    }
}


extension VocabularyCollectionCoordinator: VocabularyAdder {
    
    func addNewVocabulary(to collection: VocabularyCollection) {
        let vocabularyVC = VocabularyViewController(mode: .create(collection))
        vocabularyVC.coordinator = self
        vocabularyVC.navigationItem.title = "New Vocabulary"
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
    
    func removeVocabulary(_ vocabulary: Vocabulary, from collection: VocabularyCollection, sender: UIView) {
        guard collection.vocabularies.contains(vocabulary) else { return }
        let alert = UIAlertController(title: "Delete Vocabulary", message: nil, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            collection.managedObjectContext?.perform {
                collection.managedObjectContext?.delete(vocabulary)
                collection.managedObjectContext?.quickSave()
            }
        }
        alert.addAction(delete)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = [.right]
        }
        navigationController.present(alert, animated: true, completion: nil)
    }
}


extension VocabularyCollectionCoordinator: UserProfileViewer {
    
    func viewUserProfile() {
        let collectionListVC = UserProfileViewController(user: CoreDataStack.current.user())
        collectionListVC.doneTappedHandler = { [weak self] in
            self?.vocabularyCollectionVC.setCollection(collectionListVC.selectedCollection)
            collectionListVC.dismiss(animated: true, completion: nil)
        }
        let collectionListVCWithNav = collectionListVC.withNavController()
        if UIDevice.current.userInterfaceIdiom == .pad {
            collectionListVCWithNav.modalPresentationStyle = .formSheet
        }
        navigationController.present(collectionListVCWithNav, animated: true, completion: nil)
    }
}
