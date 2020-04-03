//
//  ModalTextFieldModel.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct ModalTextFieldModel {
    var text = ""
    var placeholder = ""
    
    var title = ""
    var prompt = ""
    var promptColor: Color?
    
    var tokens: [String] = []
    var showClearTokenIndicator = false
    
    var isFirstResponder = false
    
    var returnKeyType: UIReturnKeyType = .done
    
    /// An action for *Cancel* nav button.
    var onCancel: (() -> Void)?
    
    /// An action for *Done* nav button.
    var onCommit: (() -> Void)?
    
    /// An action for keyboard return key.
    var onReturnKey: (() -> Void)?
    
    /// An action for token tapped.
    var onTokenSelected: ((String) -> Void)?
}
