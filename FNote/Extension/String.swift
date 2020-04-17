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
    
    func trimmedUsername() -> String {
        let allows = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"
        let username = self.filter({ allows.contains($0) })
        return username
    }
    
    func isEmptyOrWhiteSpaces() -> Bool {
        self.trimmed().isEmpty
    }
}
