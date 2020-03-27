//
//  UserPreference.swift
//  FNote
//
//  Created by Dara Beng on 1/30/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


class UserPreference: ObservableObject {
    
    static let shared = UserPreference()
    
    
    // MARK: iCloud
        
    @UserStoredValue(in: .iCloud, key: key("useMarkdown"), defaultValue: true)
    var useMarkdown: Bool
    
    @UserStoredValue(in: .iCloud, key: key("useMarkdownSoftBreak"), defaultValue: true)
    var useMarkdownSoftBreak: Bool
    
    @UserStoredValue(in: .iCloud, key: key("generalKeyboardUsage"), defaultValue: true)
    var showGeneralKeyboardUsage: Bool
    
    
    // MARK: User Defaults
    
    let colorSchemeKey = key("colorScheme")
    var colorScheme: ColorScheme {
        set {
            UserStoredValue.Storage.userDefaults.setValue(newValue.rawValue, forKey: colorSchemeKey)
        }
        get {
            let storage = UserStoredValue<Int>.Storage.userDefaults
            let defaultValue = ColorScheme.system
            let rawValue = storage.value(forKey: colorSchemeKey, defaultValue: defaultValue.rawValue)
            return ColorScheme(rawValue: rawValue) ?? defaultValue
        }
    }
    
    @UserStoredValue(in: .userDefaults, key: key("noteCardSortOptionAscending"), defaultValue: true)
    var noteCardSortOptionAscending: Bool
    
    let noteCardSortOptionKey = key("noteCardSortOption")
    var noteCardSortOption: NoteCardSortOption {
        set {
            UserStoredValue.Storage.userDefaults.setValue(newValue.rawValue, forKey: noteCardSortOptionKey)
        }
        get {
            let storage = UserStoredValue<Int>.Storage.userDefaults
            let defaultValue = NoteCardSortOption.translation
            let rawValue = storage.value(forKey: noteCardSortOptionKey, defaultValue: defaultValue.rawValue)
            return NoteCardSortOption(rawValue: rawValue) ?? defaultValue
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
