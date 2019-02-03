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
    var mainCoordinator: MainCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupMainCoordinator()
        CloudKitService.current.checkAccountStatus()
        CloudKitService.current.checkAccountID()
        return true
    }
}


extension AppDelegate {
    
    private func setupMainCoordinator() {
        let navController = UINavigationController()
        mainCoordinator = MainCoordinator(navController: navController)
        mainCoordinator?.start()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
}

