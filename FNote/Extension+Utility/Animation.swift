//
//  Animation.swift
//  FNote
//
//  Created by Dara Beng on 2/26/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


extension UIView {
    
    func shakeHorizontally(duration: TimeInterval = 0.3) {
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        animation.values = [center.x, center.x + 10, center.x, center.x - 10, center.x]
        animation.repeatCount = 2
        animation.duration = duration
        layer.add(animation, forKey: animation.keyPath)
    }
}
