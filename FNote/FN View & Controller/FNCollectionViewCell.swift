//
//  FNCollectionViewCell.swift
//  FNote
//
//  Created by Dara Beng on 1/17/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit
import Combine
import CoreData


class FNCollectionViewCell<Object>: UICollectionViewCell where Object: NSManagedObject {
        
    private(set) var object: Object?
    
    /// A subscription to reload cell on received `objectWillChange`.
    private(set) var subscription: AnyCancellable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        object = nil
    }
    
    func reload(with object: Object) {
        self.object = object
        setupSubscription()
    }
    
    func initCell() {
        setupCell()
        setupConstraints()
    }
    
    func setupCell() {}
    
    func setupConstraints() {}
}


extension FNCollectionViewCell {
    
    private func setupSubscription() {
        subscription = object?
            .objectWillChange
            .eraseToAnyPublisher()
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] a in
                guard let self = self else { return }
                guard let object = self.object else { return }
                guard object.managedObjectContext != nil else { return }
                self.reload(with: object)
            })
    }
}
