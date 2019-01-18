//
//  MainTabBarViewController.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    let vocabularyCollectionVC: VocabularyCollectionViewController = {
        let vc = VocabularyCollectionViewController()
        vc.tabBarItem = UITabBarItem(title: "Collections", image: .tabBarVocabCollection, tag: 0)
        vc.navigationItem.title = vc.tabBarItem.title
        return vc
    }()
    
    let vocabularyVC: VocabularyViewController = {
        let vc = VocabularyViewController()
        vc.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        vc.navigationItem.title = "Vocabulary"
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        navigationItem.title = viewController.navigationItem.title
    }
}


extension MainTabBarViewController {
    
    private func setupControllers() {
        view.backgroundColor = .white
        viewControllers = [vocabularyCollectionVC, vocabularyVC]
        selectedViewController = viewControllers?.first
        navigationItem.title = selectedViewController?.navigationItem.title
        delegate = self
    }
}
