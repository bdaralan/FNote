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
    let localized: String
    
    
    private init(code: String, localized: String) {
        self.code = code
        self.localized = localized
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }
    
    /// Load all available language from system's available language ISO codes.
    static func availableISO639s() -> [Language] {
        Locale.isoLanguageCodes.compactMap { code -> Language? in
            guard let localized = Locale.current.localizedString(forLanguageCode: code) else { return nil }
            return Language(code: code, localized: localized)
        }
        .sorted(by: { $0.localized < $1.localized })
    }
}
