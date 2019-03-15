//
//  GuideView.swift
//  FNote
//
//  Created by Dara Beng on 3/14/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol GuideView: AnyObject {
    
    func show(in superview: UIView)
    
    func remove()
}
