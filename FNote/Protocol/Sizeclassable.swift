//
//  Sizeclassable.swift
//  FNote
//
//  Created by Dara Beng on 5/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol Sizeclassable: UIView {
    
    func configureConstraints(for trait: UITraitCollection, interfaceIdiom: UIUserInterfaceIdiom)
}
