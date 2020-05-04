//
//  String.swift
//  FNote
//
//  Created by Dara Beng on 9/4/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


extension String {
    
    /// Trim all whitespaces and newline characters.
    func trimmed() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Trim all whitespaces and commas.
    /// - Returns: The trimmed and lowercased string.
    func trimmedComma() -> String {
        self.replacingOccurrences(of: ",", with: "").trimmed()
    }
    
    func trimmedPipe() -> String {
        self.replacingOccurrences(of: "|", with: "").trimmed()
    }
    
    func trimmedUsername() -> String {
        let allows = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"
        let username = self.filter({ allows.contains($0) })
        return username
    }
    
    func isEmptyOrWhiteSpaces() -> Bool {
        self.trimmed().isEmpty
    }
}


extension String {
    
    /// Create string with the given quantity and single or plural unit.
    /// - Parameters:
    ///   - quantity: The quantity number.
    ///   - singular: The unit in singular form.
    ///   - plural: The unit in plural form.
    ///   - separator: The separator between the quantity and unit. The default is whitespace.
    init(quantity: Int, singular: String, plural: String, separator: String = " ") {
        let unit = quantity == 1 ? singular : plural
        self.init("\(quantity)\(separator)\(unit)")
    }
}
