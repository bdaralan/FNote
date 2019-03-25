//
//  CustomAlert.swift
//  FNote
//
//  Created by Dara Beng on 3/24/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


struct CustomAlert {}


extension CustomAlert {
    
    static func showFeatureNotAvailable(presenter: UIViewController) {
        let title = "Feature Not Available"
        let message = "Developers have not implemented this feature"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Dismiss", style: .default, handler: nil))
        presenter.present(alert, animated: true, completion: nil)
    }
}
