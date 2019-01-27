//
//  MainTabBarViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit
import CoreData

class MainTabBarViewController: UITabBarController {
    
    private var vocabularyCollectionVC: VocabularyCollectionViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
        setupCloudKitNotificationHandler()
    }
    
    @objc private func handleCloudKitUserRecordIDNameChanged() {
        DispatchQueue.main.async { [unowned self] in
            CoreDataStack.current.changePersistentStore(forUserRecordIDName: CloudKitService.current.userRecordIDName)
            let collection = CoreDataStack.current.user()!.collections.first!
            self.vocabularyCollectionVC.reloadCollection(collection)
        }
    }
}


// MARK: - TabBar Controller Delegate

extension MainTabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        reloadNavItem(with: viewController)
    }
}


extension MainTabBarViewController {
    
    private func setupControllers() {
        setupVocabularyCollectionController()
        delegate = self
        view.backgroundColor = .white
        viewControllers = [vocabularyCollectionVC]
        selectedViewController = vocabularyCollectionVC
        reloadNavItem(with: selectedViewController!)
    }
    
    private func setupVocabularyCollectionController() {
        #warning("TODO: let user chooses which collections to view")
        let user = CoreDataStack.current.user()!
        let collection = user.collections.first!
        let vc = VocabularyCollectionViewController(collection: collection)
        vc.tabBarItem = UITabBarItem(title: "Collections", image: .tabBarVocabCollection, tag: 0)
        vc.navigationItem.title = collection.name
        vocabularyCollectionVC = vc
    }
    
    private func reloadNavItem(with viewController: UIViewController) {
        navigationItem.title = viewController.navigationItem.title
        navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems
    }
    
    private func setupCloudKitNotificationHandler() {
        let action = #selector(handleCloudKitUserRecordIDNameChanged)
        NotificationCenter.default.addObserver(self, selector: action, name: CloudKitService.nUserRecordIDNameDidChange, object: nil)
    }
}
