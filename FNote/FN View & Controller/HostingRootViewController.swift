//
//  HostingRootViewController.swift
//  FNote
//
//  Created by Dara Beng on 2/14/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


class HostingRootViewController<Content>: UIHostingController<Content> where Content: View {
    
    var appState: AppState?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard UIDevice.current.userInterfaceIdiom != .pad else { return .all }
        let lockPortraitMode = appState?.lockPortraitMode ?? false
        return lockPortraitMode ? UIInterfaceOrientationMask.portrait : .allButUpsideDown
    }
}
