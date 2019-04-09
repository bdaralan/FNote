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
    
    var isTabBarVisible: Bool {
        return tabBar.frame.origin.y < view.bounds.height
    }
    
    private var tabBarOnScreenY: CGFloat {
        return view.bounds.height - tabBar.bounds.height
    }
    
    private var tabBarOffScreenY: CGFloat {
        return view.bounds.height
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupUserAccountTokenChangedNotification()
    }
    
    
    func toggleTabBar(visible: Bool) {
        guard visible != isTabBarVisible else { return }
        UIView.animate(withDuration: 0.15) { [weak self] in
            guard let self = self else { return }
            self.tabBar.frame.origin.y = visible ? self.tabBarOnScreenY : self.tabBarOffScreenY
        }
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
            let coreData = CoreDataStack.current
            let recordName = AppDefaults.standard.selectedCollectionRecordName ?? ""
            let collection = coreData.fetchVocabularyCollection(recordName: recordName, context: coreData.mainContext)
            self.vocabularyCollectionCoordinator.vocabularyCollectionVC.setCollection(collection)
        }
    }
}
