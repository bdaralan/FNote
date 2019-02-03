//
//  MainCoordinator.swift
//  FNote
//
//  Created by Dara Beng on 2/3/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


class MainCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    
    var children: [Coordinator] = []

    
    init(navController: UINavigationController) {
        navigationController = navController
    }
    
    func start() {
        let mainTabBarController = MainTabBarViewController()
        navigationController.pushViewController(mainTabBarController, animated: false)
    }
}
