//
//  ManagedObjectCollectionViewCell.swift
//  FNote
//
//  Created by Dara Beng on 1/31/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit
import CoreData
import Combine


class ManagedObjectCollectionViewCell<Object>: FNCollectionViewCell<Object> where Object: NSManagedObject {
    
    /// A subscription to reload cell on received `objectWillChange`.
    private(set) var subscription: AnyCancellable?
    
    override func reload(with object: Object) {
        super.reload(with: object)
        setupSubscription()
    }
    
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
