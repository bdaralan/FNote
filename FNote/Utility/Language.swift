//
//  Language.swift
//  FNote
//
//  Created by Dara Beng on 3/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation


struct Language: Equatable {
    
    /// ISO-639 language code
    let code: String
    
    /// Language localized string of the `code`.
    var localized: String {
        Locale.current.localizedString(forLanguageCode: code) ?? "???"
    }
    
    
    // MARK: Constructor
    
    init(code: String) {
        self.code = code
    }
    
    
    // MARK: Equatable
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }
}


// MARK: - System

extension Language {
    
    /// Load all available language from system's available language ISO codes.
    static let availableISO639s: [Language] = {
        Locale.isoLanguageCodes.compactMap { code -> Language? in
            guard Locale.current.localizedString(forLanguageCode: code) != nil else { return nil }
            return Language(code: code)
        }
        .sorted(by: { $0.localized < $1.localized })
    }()
}
