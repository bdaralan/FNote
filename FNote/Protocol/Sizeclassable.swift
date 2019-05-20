//
//  SizeClassable.swift
//  FNote
//
//  Created by Dara Beng on 5/19/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


protocol SizeClassable: UIView {
    
    var currentSizeClassConstraints: [NSLayoutConstraint] { set get }
    
    func configureSizeClassConstraints(for trait: UITraitCollection, interfaceIdiom: UIUserInterfaceIdiom) -> [NSLayoutConstraint]
}
