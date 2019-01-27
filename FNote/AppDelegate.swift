//
//  AppDelegate.swift
//  FNote
//
//  Created by Dara Beng on 1/17/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootNavController: UINavigationController!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupRootViewController()
        CloudKitService.current.checkAccountStatus()
        CloudKitService.current.checkAccountID()
        return true
    }
}


extension AppDelegate {
    
    private func setupRootViewController() {
        let tabBarVC = MainTabBarViewController()
        rootNavController = UINavigationController(rootViewController: tabBarVC)
        rootNavController.navigationBar.prefersLargeTitles = true
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootNavController
        window?.makeKeyAndVisible()
    }
}

