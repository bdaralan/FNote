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
    
    var isFirstResponder = false
    
    var onCancel: (() -> Void)?
    var onCommit: (() -> Void)?
}
