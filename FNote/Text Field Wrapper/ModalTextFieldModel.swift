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
    
    var isFirstResponder = false
    
    var returnKeyType: UIReturnKeyType = .done
    
    /// Action for *Cancel* nav button.
    var onCancel: (() -> Void)?
    
    /// Action for *Done* nav button.
    var onCommit: (() -> Void)?
    
    /// Action for keyboard return key.
    var onReturnKey: (() -> Void)?
    
    /// Action for token tapped.
    var onTokenSelected: ((String) -> Void)?
}
