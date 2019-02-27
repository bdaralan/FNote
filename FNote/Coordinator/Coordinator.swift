//
//  Coordinator.swift
//  FNote
//
//  Created by Dara Beng on 2/3/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol Coordinator {
    
    var children: [Coordinator] { set get }
    
    var navigationController: UINavigationController { set get }
    
    
    func start()
}
