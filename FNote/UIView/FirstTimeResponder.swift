//
//  FirstTimeResponder.swift
//  FNote
//
//  Created by Dara Beng on 9/15/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol FirstTimeResponder: class {
    
    var isActive: Bool { set get }
    
    var shouldResponse: Bool { set get }
    
    func handleFirstResponse(for responder: UIView, isActive: Bool)
    
    func resignResponder(_ responder: UIView, reset: Bool)
}


extension FirstTimeResponder {
    
    func handleFirstResponse(for responder: UIView, isActive: Bool) {
        self.isActive = isActive
        
        let didAppear = responder.window != nil
        let willAppear = responder.window == nil
        
        if willAppear {
            shouldResponse = true
        }
        
        if isActive, shouldResponse, didAppear, !responder.isFirstResponder {
            responder.becomeFirstResponder()
            shouldResponse = false
        }
    }
    
    func resignResponder(_ responder: UIView, reset: Bool) {
        responder.resignFirstResponder()
        guard reset else { return }
        shouldResponse = true
    }
}
