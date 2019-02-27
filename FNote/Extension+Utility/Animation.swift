//
//  Animation.swift
//  FNote
//
//  Created by Dara Beng on 2/26/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


private let animationCache: NSCache<NSString, CAPropertyAnimation> = {
    let cache = NSCache<NSString, CAPropertyAnimation>()
    cache.countLimit = 3
    return cache
}()


extension UIView {
    
    func shakeHorizontally(duration: TimeInterval = 0.3) {
        let cacheKey: NSString = "shakeHorizontally"
        if let animation = animationCache.object(forKey: cacheKey) {
            layer.add(animation, forKey: animation.keyPath)
        } else {
            let animation = CAKeyframeAnimation(keyPath: "position.x")
            let centerX = center.x
            animation.values = [centerX, centerX + 10, centerX, centerX - 10, centerX]
            animation.repeatCount = 2
            animation.duration = duration
            layer.add(animation, forKey: nil)
            animationCache.setObject(animation, forKey: cacheKey)
        }
    }
}
