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
    
    func handleFirstResponder(for responder: UIView, isFirstResponder: Bool) {
        if isFirstResponder {
            guard !responder.isFirstResponder, responder.window != nil else { return }
            responder.becomeFirstResponder()
        } else {
            guard responder.isFirstResponder else { return }
            responder.resignFirstResponder()
        }
    }
}
