//
//  Language.swift
//  FNote
//
//  Created by Dara Beng on 3/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation


struct Language: Equatable {
    
    let code: String
    
    let localized: String
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }
    
    static func fromISOCodes() -> [Language] {
        Locale.isoLanguageCodes.compactMap { code -> Language? in
            guard let localized = Locale.current.localizedString(forLanguageCode: code) else { return nil }
            return Language(code: code, localized: localized)
        }
        .sorted(by: { $0.localized < $1.localized })
    }
}
