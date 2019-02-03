//
//  Coordinator.swift
//  FNote
//
//  Created by Dara Beng on 2/3/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol Coordinator {
    
    var navigationController: UINavigationController { set get }
    var children: [Coordinator] { set get }
    
    func start()
}
