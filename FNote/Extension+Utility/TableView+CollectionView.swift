//
//  TableView+CollectionView.swift
//  UIPrototype
//
//  Created by Dara Beng on 1/8/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


extension UIView {
    
    /// Return the class name.
    static var className: String {
        return String(describing: self)
    }
}


extension UITableView {
    
    /// Register a cell using its class name as the identifier.
    func registerCell<T>(_ cellType: T.Type) where T: UITableViewCell {
        register(cellType.self, forCellReuseIdentifier: cellType.className)
    }
    
    /// Dequeue a registered cell using its class name as the identifier.
    func dequeueRegisteredCell<T>(_ cellType: T.Type, for indexPath: IndexPath) -> T where T: UITableViewCell {
        return dequeueReusableCell(withIdentifier: cellType.className, for: indexPath) as! T
    }
    
    /// Register a header or footer using its class name as the identifier.
    func registerHeaderFooter<T>(_ type: T.Type) where T: UITableViewHeaderFooterView {
        register(type.self, forHeaderFooterViewReuseIdentifier: type.className)
    }
    
    /// Dequeue a registered header or footer using its class name as the identifier.
    func dequeueRegisteredHeaderFooter<T>(_ type: T.Type) -> T where T: UITableViewHeaderFooterView {
        return dequeueReusableHeaderFooterView(withIdentifier: type.className) as! T
    }
}


extension UITableView {
    
    func reloadVisibleRows(animation: UITableView.RowAnimation) {
        guard let visibleIndexPaths = indexPathsForVisibleRows else { return }
        reloadRows(at: visibleIndexPaths, with: animation)
    }
}


extension UICollectionView {
    
    /// Register a cell using its class name as the identifier.
    func registerCell<T>(_ cellType: T.Type) where T: UICollectionViewCell {
        register(cellType.self, forCellWithReuseIdentifier: cellType.className)
    }
    
    /// Dequeue a registered cell using its class name as the identifier.
    func dequeueRegisteredCell<T>(_ cellType: T.Type, for indexPath: IndexPath) -> T where T: UICollectionViewCell {
        return dequeueReusableCell(withReuseIdentifier: cellType.className, for: indexPath) as! T
    }
}
