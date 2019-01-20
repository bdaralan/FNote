//
//  MainTabBarViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    let vocabularyCollectionVC: VocabularyCollectionViewController = {
        let vc = VocabularyCollectionViewController()
        vc.tabBarItem = UITabBarItem(title: "Collections", image: .tabBarVocabCollection, tag: 0)
        vc.navigationItem.title = vc.tabBarItem.title
        return vc
    }()
    
    let vocabularyVC: VocabularyViewController = {
        let vc = VocabularyViewController(vocabulary: nil)
        vc.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        vc.navigationItem.title = "Vocabulary"
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
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
        delegate = self
        view.backgroundColor = .white
        viewControllers = [vocabularyCollectionVC, vocabularyVC]
        selectedViewController = vocabularyCollectionVC
        reloadNavItem(with: selectedViewController!)
    }
    
    private func reloadNavItem(with viewController: UIViewController) {
        navigationItem.title = viewController.navigationItem.title
        navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems
    }
}
