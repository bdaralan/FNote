//
//  SceneDelegate.swift
//  FNote
//
//  Created by Dara Beng on 8/26/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit
import SwiftUI


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let appState = AppState(parentContext: CoreDataStack.current.mainContext)


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        setupPublicUserRecord()
        setupOnboardState()
        
        // setup app state
        appState.fetchCurrentNoteCards()
        appState.lowercaseAllTagsIfAny()
        
        // setup window & home view
        let window = UIWindow(windowScene: windowScene)
        
        let homeView = HomeView()
            .environmentObject(appState)
            .environment(\.managedObjectContext, appState.parentContext)
        
        let rootViewCV = UIHostingController(rootView: homeView)
        
        window.rootViewController = rootViewCV
        
        // setup appearance
        window.tintColor = .appAccent
        appState.preference.applyColorScheme()
        UISwitch.appearance().onTintColor = .appAccent
        
        // make key and visible
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}


extension SceneDelegate {
    
    func setupPublicUserRecord() {
        let recordManager = PublicRecordManager.shared
        
        // create initial user if needed and cache the info for offline access.
        recordManager.createInitialPublicUserRecord(withData: nil) { result in
            guard case let .success(record) = result else { return }
            let user = PublicUser(record: record)
            AppCache.cachePublicUser(user)
        }
        
        if AppCache.hasSetupUserUpdateCKSubscription == false {
            recordManager.setupPublicUserRecordChangeSubscriptions { result in
                guard case .success = result else { return }
                AppCache.hasSetupUserUpdateCKSubscription = true
            }
        }
    }
    
    func setupOnboardState() {
        let lastKnownVersion = AppCache.lastKnownVersion
        let currentVersion = Bundle.main.appVersion
        if lastKnownVersion == nil || lastKnownVersion != currentVersion {
            AppCache.lastKnownVersion = currentVersion
            AppCache.shouldShowOnboard = true
        }
    }
}
