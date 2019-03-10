//
//  MainTabBarViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit
import CoreData

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    let vocabularyCollectionCoordinator = VocabularyCollectionCoordinator(navigationController: .init())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupUserAccountTokenChangedNotification()
    }
}


extension MainTabBarViewController {
    
    private func setupViewControllers() {
        let coordinators = [vocabularyCollectionCoordinator]
        viewControllers = coordinators.compactMap({ $0.navigationController })
        coordinators.forEach({ $0.start() })
    }
    
    private func setupUserAccountTokenChangedNotification() {
        let action = #selector(handleUserAccountChanged)
        NotificationCenter.default.addObserver(self, selector: action, name: .CKAccountChanged, object: nil)
    }
    
    @objc private func handleUserAccountChanged() {
        let iCloudToken = CloudKitService.accountToken
        let coreDataToken = CoreDataStack.current.userAccountToken
        guard coreDataToken != iCloudToken else { return }
        CoreDataStack.current.setPersistentStore(userAccountToken: iCloudToken)
        DispatchQueue.main.async { [unowned self] in
            self.selectedViewController = self.vocabularyCollectionCoordinator.navigationController
            let collection = CoreDataStack.current.allVocabularyCollections().first!
            self.vocabularyCollectionCoordinator.vocabularyCollectionVC.setCollection(collection)
        }
    }
}
