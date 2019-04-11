//
//  NavigationItemTogglable.swift
//  FNote
//
//  Created by Dara Beng on 4/7/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


/// Provide methods to show or hide a cancel and a done navigation bar item.
@objc protocol NavigationItemTogglable: AnyObject {

    var navigationItem: UINavigationItem { get }
    
    /// A completion block that get called when the done bar item tapped.
    var doneCompletion: (() -> Void)? { set get }
    
    /// A completion block that get called when the cancel bar item tapped.
    var cancelCompletion: (() -> Void)? { set get }
    
    @objc func doneBarItemTapped()
    @objc func cancelBarItemTapped()
}


extension NavigationItemTogglable {
    
    /// Show or hide cancel and done navigation items.
    /// The left and right navigation items will be configured to cancel and done.
    func toggleNavigationItems(showCancel: Bool, showDone: Bool, animated: Bool) {
        let done = showDone ? UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarItemTapped)) : nil
        let cancel = showCancel ? UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarItemTapped)) : nil
        navigationItem.setRightBarButton(done, animated: animated)
        navigationItem.setLeftBarButton(cancel, animated: animated)
    }
}
