//
//  ObjectValidatable.swift
//  FNote
//
//  Created by Dara Beng on 9/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


/// A protocol for validating object.
protocol ObjectValidatable {
    
    /// Check if the object has all the required properties.
    func isValid() -> Bool
    
    /// Check if the object has valid inputs from the user.
    func hasValidInputs() -> Bool
    
    /// Check if the object has changed values and should be saved.
    func hasChangedValues() -> Bool
}
