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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAccountTokenChangedHandler(actived: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setupAccountTokenChangedHandler(actived: false)
    }
    
    @objc private func handleUserAccountChanged(notification: Notification) {
        guard let accountToken = notification.object as? String else { return }
        guard accountToken != CoreDataStack.current.userAccountToken else { return }
        CoreDataStack.current.setPersistentStore(forUserAccountToken: accountToken)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let collection = CoreDataStack.current.firstCollection()!
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
        let collection = CoreDataStack.current.firstCollection()!
        vocabularyCollectionVC = VocabularyCollectionViewController(collection: collection)
        vocabularyCollectionVC.tabBarItem = UITabBarItem(title: "Collections", image: .tabBarVocabCollection, tag: 0)
        vocabularyCollectionVC.navigationItem.title = collection.name
    }
    
    private func reloadNavItem(with viewController: UIViewController) {
        navigationItem.title = viewController.navigationItem.title
        navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems
    }
    
    private func setupAccountTokenChangedHandler(actived: Bool) {
        let name = CloudKitService.nameUserAccountTokenDidChange
        let action = #selector(handleUserAccountChanged(notification:))
        let notificationCenter = NotificationCenter.default
        if actived {
            notificationCenter.addObserver(self, selector: action, name: name, object: nil)
        } else {
            notificationCenter.removeObserver(self)
        }
    }
}
