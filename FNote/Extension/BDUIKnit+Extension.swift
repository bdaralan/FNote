//
//  BDUIKnit+Extension.swift
//  FNote
//
//  Created by Dara Beng on 4/16/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import BDUIKnit
import SwiftUI


// MARK: - Button Tray

extension BDButtonTrayViewModel {
    
    func setDefaultColors() {
        buttonActiveColor = Color.accentColor
        buttonInactiveColor = Color(.quaternaryLabel)
        itemActiveColor = Color.accentColor
        itemInactiveColor = Color(.quaternaryLabel)
        subitemActiveColor = Color.accentColor
        subitemInactiveColor = Color(.quaternaryLabel)
        expandIndicatorColor = Color.secondary
        trayColor = Color.buttonTray
        trayShadowColor = Color.buttonTrayShadow
    }
}
