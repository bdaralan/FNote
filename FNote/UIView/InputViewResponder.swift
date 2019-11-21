//
//  InputViewResponder.swift
//  FNote
//
//  Created by Dara Beng on 9/15/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol InputViewResponder {}


extension InputViewResponder {
    
    func setActive(to active: Bool, for responder: UIView) {
        if active {
            guard !responder.isFirstResponder, responder.window != nil else { return }
            responder.becomeFirstResponder()
        } else {
            responder.resignFirstResponder()
        }
    }
}
