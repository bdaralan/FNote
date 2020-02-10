//
//  ModalTextViewModel.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation


struct ModalTextViewModel {
    
    var text = ""
    var title = ""
    var isFirstResponder = false
    
    var disableEditing = false
    var renderMarkdown = false
    var renderSoftBreak = false
    
    var onCommit: (() -> Void)?
}
