//
//  NavigationBarItemTogglable.swift
//  FNote
//
//  Created by Dara Beng on 4/7/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


/// Provide methods to show or hide a cancel and a done navigation bar item.
@objc protocol NavigationItemTogglable: AnyObject {
    
    var navigationItem: UINavigationItem { get }
    
    var cancelCompletion: (() -> Void)? { set get }
    var doneCompletion: (() -> Void)? { set get }
    
    @objc func cancelBarItemTapped()
    @objc func doneBarItemTapped()
}


extension NavigationItemTogglable {
    
    func toggleNavigationItems(showCancel: Bool, showDone: Bool, animated: Bool) {
        let cancel = showCancel ? UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarItemTapped)) : nil
        let done = showDone ? UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarItemTapped)) : nil
        navigationItem.setLeftBarButton(cancel, animated: animated)
        navigationItem.setRightBarButton(done, animated: animated)
    }
}
