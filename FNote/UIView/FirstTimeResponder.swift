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
    
    var shouldAutoShowKeyboard: Bool { set get }
    
    func handleFirstResponse(for responder: UIView, isActive: Bool)
    
    func resignResponder(_ responder: UIView, reset: Bool)
}


extension FirstTimeResponder {
    
    func handleFirstResponse(for responder: UIView, isActive: Bool) {
        self.isActive = isActive
        
        let willAppear = responder.window == nil
        let didAppear = responder.window != nil
        
        if willAppear {
            shouldAutoShowKeyboard = true
        }
        
        if shouldAutoShowKeyboard, isActive, didAppear {
            shouldAutoShowKeyboard = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // set small a delay
                responder.becomeFirstResponder()
            }
        }
        
        if !isActive {
            shouldAutoShowKeyboard = true
        }
    }
    
    func resignResponder(_ responder: UIView, reset: Bool) {
        responder.resignFirstResponder()
        guard reset else { return }
        shouldAutoShowKeyboard = true
    }
}
