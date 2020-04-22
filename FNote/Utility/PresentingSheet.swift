//
//  PresentingSheet.swift
//  FNote
//
//  Created by Dara Beng on 4/3/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation


/// A convenient object use to interact with `View.sheet(item:)`.
///
/// The object provides a way to set the presenting sheet and
/// also keep track of the last presented sheet.
struct PresentingSheet<Sheet> where Sheet: PresentationSheetItem {
    
    // MARK: Property
    
    /// The current active sheet.
    var presenting: Sheet? {
        didSet {
            guard oldValue != nil else { return }
            lastPresented = oldValue
        }
    }
    
    /// The last presented sheet.
    private(set) var lastPresented: Sheet?
    
    
    // MARK: Method
    
    /// Dismiss the presenting sheet.
    ///
    /// This is the same as setting `presenting` to `nil`.
    mutating func dismiss() {
        presenting = nil
    }
    
    /// Present the given sheet.
    ///
    /// This is the same as setting `presenting` value.
    mutating func present(_ sheet: Sheet) {
        presenting = sheet
    }
}


// MARK: - Presenting Sheet Item

protocol PresentationSheetItem: Identifiable {}

extension PresentationSheetItem {
    var id: Self { self }
}
