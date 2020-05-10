//
//  UserPreference.swift
//  FNote
//
//  Created by Dara Beng on 1/30/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit
import BDUIKnit


class UserPreference: ObservableObject {
    
    static let shared = UserPreference()
    
    
    // MARK: iCloud
        
    @BDPersist(in: .ubiquitousStore, key: key("useMarkdown"), default: true)
    var useMarkdown: Bool
    
    @BDPersist(in: .ubiquitousStore, key: key("useMarkdownSoftBreak"), default: true)
    var useMarkdownSoftBreak: Bool
    
    @BDPersist(in: .ubiquitousStore, key: key("generalKeyboardUsage"), default: true)
    var showGeneralKeyboardUsage: Bool
    
    
    // MARK: User Defaults
    
    let colorSchemeKey = key("colorScheme")
    var colorScheme: ColorScheme {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: colorSchemeKey)
        }
        get {
            let defaults = UserDefaults.standard
            let defaultValue = ColorScheme.system
            let rawValue = defaults.object(forKey: colorSchemeKey) as? Int ?? defaultValue.rawValue
            return ColorScheme(rawValue: rawValue) ?? defaultValue
        }
    }
    
    @BDPersist(in: .userDefaults, key: key("noteCardSortOptionAscending"), default: true)
    var noteCardSortOptionAscending: Bool
    
    let noteCardSortOptionKey = key("noteCardSortOption")
    var noteCardSortOption: NoteCard.SearchField {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: noteCardSortOptionKey)
        }
        get {
            let defaults = UserDefaults.standard
            let defaultValue = NoteCard.SearchField.translation.rawValue
            let rawValue = defaults.object(forKey: noteCardSortOptionKey) as? String ?? defaultValue
            return NoteCard.SearchField(rawValue: rawValue)!
        }
    }
    
    
    private init() {}
    
    
    func applyColorScheme() {
        for window in UIApplication.shared.windows {
            window.overrideUserInterfaceStyle = colorScheme.userInterfaceStyle
        }
    }
}


extension UserPreference {
    
    enum ColorScheme: Int {
        case system
        case light
        case dark
        
        var userInterfaceStyle: UIUserInterfaceStyle {
            switch self {
            case .system: return .unspecified
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
}


private func key(_ appending: String) -> String {
    "kUserPreference.\(appending)"
}
