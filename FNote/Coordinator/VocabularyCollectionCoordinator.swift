//
//  VocabularyCollectionCoordinator.swift
//  FNote
//
//  Created by Dara Beng on 2/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit
import CoreData


class VocabularyCollectionCoordinator: NSObject, Coordinator, UINavigationControllerDelegate {
    
    var children: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    var vocabularyCollectionVC: VocabularyCollectionViewController!
    
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.navigationBar.prefersLargeTitles = true
    }
    
    
    func start() {
        let coreData = CoreDataStack.current
        let recordName = AppDefaults.standard.selectedCollectionRecordName ?? ""
        let collection = coreData.fetchVocabularyCollection(recordName: recordName, context: coreData.mainContext)
        vocabularyCollectionVC = VocabularyCollectionViewController(collection: collection)
        vocabularyCollectionVC.coordinator = self
        navigationController.delegate = self
        navigationController.tabBarItem = UITabBarItem(title: "Collection", image: .tabBarVocabCollection, tag: 0)
        navigationController.pushViewController(vocabularyCollectionVC, animated: false)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard viewController !== vocabularyCollectionVC, navigationController.viewControllers.contains(viewController) else { return }
        AppDelegate.default?.mainTabBarViewController.toggleTabBar(visible: false)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard viewController === vocabularyCollectionVC else { return }
        AppDelegate.default?.mainTabBarViewController.toggleTabBar(visible: true)
    }
}


// MARK: - Vocabulary Viewer
extension VocabularyCollectionCoordinator: VocabularyViewable {
    
    func addNewVocabulary(to collection: VocabularyCollection) {
        let vocabularyVC = VocabularyViewController(mode: .create(collection))
        let embedNavController = vocabularyVC.embedNavigationController()
        vocabularyVC.coordinator = self
        vocabularyVC.navigationItem.title = "New Vocabulary"
        vocabularyVC.saveCompletion = { (result) in
            embedNavController.dismiss(animated: true, completion: nil)
        }
        navigationController.present(embedNavController, animated: true, completion: nil)
    }
    
    func viewVocabulary(_ vocabulary: Vocabulary) {
        let vocabularyVC = VocabularyViewController(mode: .view(vocabulary))
        vocabularyVC.coordinator = self
        vocabularyVC.navigationItem.title = "Vocabulary"
        vocabularyVC.saveCompletion = { [weak self] (result) in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(vocabularyVC, animated: true)
    }
    
    func selectPoliteness(for vocabularyVC: VocabularyViewController, current: Vocabulary.Politeness) {
        let politenesses = Vocabulary.Politeness.allCases
        let options = politenesses.map({ OptionTableViewController.Option(name: $0.displayText, isSelected: $0 == current) })
        
        let optionVC = OptionTableViewController(selectMode: .single, options: options, title: "Politeness")
        
        if let embedNavController = vocabularyVC.navigationController {
            optionVC.selectCompletion = { (index) in
                vocabularyVC.setPoliteness(politenesses[index])
                embedNavController.popViewController(animated: true)
            }
            optionVC.cancelCompletion = {
                embedNavController.popViewController(animated: true)
            }
            embedNavController.pushViewController(optionVC, animated: true)
            
        } else {
            let embedNavController = optionVC.embedNavigationController()
            optionVC.toggleNavigationItems(showCancel: true, showDone: false, animated: false)
            optionVC.cancelCompletion = {
                embedNavController.dismiss(animated: true, completion: nil)
            }
            optionVC.selectCompletion = { (index) in
                vocabularyVC.setPoliteness(politenesses[index])
                vocabularyVC.saveChanges()
                embedNavController.dismiss(animated: true, completion: nil)
            }

            if UIDevice.current.userInterfaceIdiom == .pad {
                let width = UIViewController.preferredContentSizeWidth()
                let height = optionVC.tableView.rowHeight * CGFloat(options.count) + 70
                embedNavController.preferredContentSize = CGSize(width: width, height: height)
                embedNavController.modalPresentationStyle = .formSheet
            }
            navigationController.present(embedNavController, animated: true, completion: nil)
        }
    }
    
    func selectTags(for vocabularyVC: VocabularyViewController, current: [String], existingTags: [String]) {
        let options = existingTags.map({ OptionTableViewController.Option(name: $0, isSelected: current.contains($0)) })
        let optionVC = OptionTableViewController(selectMode: .multiple, options: options, title: "Tags")
        optionVC.allowDeleteOption = true
        optionVC.allowRenameOption = true
        optionVC.allowAddNewOption = true
        optionVC.newOptionMaxCharacterCount = Tag.nameMaxCharacterCount
        optionVC.newOptionPlaceholder = "Add New Tag"
        
        optionVC.selectCompletion = { (index) in
            vocabularyVC.addTag(name: optionVC.options[index].name, create: false)
        }
        optionVC.deselectCompletion = { (index) in
            vocabularyVC.removeTag(name: optionVC.options[index].name, delete: false)
        }
        optionVC.addNewOptionCompletion = { (newTagName, index) in
            vocabularyVC.addTag(name: newTagName, create: true)
        }
        optionVC.renameOptionCompletion = { (old, updated) in
            vocabularyVC.renameTag(current: old.name, newName: updated.name)
        }
        optionVC.deleteOptionCompletion = { (deletedOption) in
            if deletedOption.isSelected {
                vocabularyVC.removeTag(name: deletedOption.name, delete: true)
            } else { // if the deleted tag is not in the vocabulary's tags, delete it from the user's available tags
                let user = CoreDataStack.current.user()
                guard let tagToDelete = user.tags.first(where: { $0.name == deletedOption.name }) else { return }
                user.managedObjectContext?.delete(tagToDelete)
                user.managedObjectContext?.quickSave()
            }
        }
        
        if let embedNavController = vocabularyVC.navigationController {
            embedNavController.pushViewController(optionVC, animated: true)
        } else {
            let embebNavController = optionVC.embedNavigationController()
            optionVC.toggleNavigationItems(showCancel: true, showDone: true, animated: false)
            optionVC.cancelCompletion = {
                embebNavController.dismiss(animated: true, completion: nil)
            }
            optionVC.doneCompletion = { 
                vocabularyVC.saveChanges()
                embebNavController.dismiss(animated: true, completion: nil)
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                embebNavController.modalPresentationStyle = .formSheet
            }
            navigationController.present(embebNavController, animated: true, completion: nil)
        }
    }
    
    func selectMoreActions(for vocabulary: Vocabulary, in collection: VocabularyCollection, sender: UIView) {
        guard collection.vocabularies.contains(vocabulary) else { return }
        let alert = UIAlertController(title: "Actions", message: nil, preferredStyle: .actionSheet)
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
    
    func selectVocabularyConnection(for vocabularyVC: VocabularyViewController) {
        let connectionVC = VocabularyConnectionViewController(sourceVocabularyID: vocabularyVC.vocabularyObjectID, context: vocabularyVC.context)
        
        if let embedNavController = vocabularyVC.navigationController {
            embedNavController.pushViewController(connectionVC, animated: true)
        } else {
            let embedNavController = connectionVC.embedNavigationController()
            connectionVC.toggleNavigationItems(showCancel: true, showDone: true, animated: false)
            connectionVC.cancelCompletion = {
                embedNavController.dismiss(animated: true, completion: nil)
            }
            connectionVC.doneCompletion = {
                embedNavController.dismiss(animated: true, completion: nil)
            }
            navigationController.present(embedNavController, animated: true, completion: nil)
        }
    }
}


// MARK: - User Profile Viewer
extension VocabularyCollectionCoordinator: UserProfileViewable {
    
    func viewUserProfile() {
        let user = CoreDataStack.current.user()
        let collectionListVC = UserProfileViewController(user: user)
        collectionListVC.doneTappedHandler = { [weak self] in
            guard let self = self else { return }
            if self.vocabularyCollectionVC.collection != collectionListVC.selectedCollection {
                self.vocabularyCollectionVC.setCollection(collectionListVC.selectedCollection)
            }
            collectionListVC.dismiss(animated: true, completion: nil)
        }
        let embedNavController = collectionListVC.embedNavigationController()
        if UIDevice.current.userInterfaceIdiom == .pad {
            embedNavController.modalPresentationStyle = .formSheet
        }
        navigationController.present(embedNavController, animated: true, completion: nil)
    }
}
