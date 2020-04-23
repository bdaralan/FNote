//
//  UserPreference.swift
//  FNote
//
//  Created by Dara Beng on 1/30/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit
import BDSwiftility


class UserPreference: ObservableObject {
    
    static let shared = UserPreference()
    
    
    // MARK: iCloud
        
    @BDStoredValue(in: .iCloud, key: key("useMarkdown"), default: true)
    var useMarkdown: Bool
    
    @BDStoredValue(in: .iCloud, key: key("useMarkdownSoftBreak"), default: true)
    var useMarkdownSoftBreak: Bool
    
    @BDStoredValue(in: .iCloud, key: key("generalKeyboardUsage"), default: true)
    var showGeneralKeyboardUsage: Bool
    
    
    // MARK: User Defaults
    
    let colorSchemeKey = key("colorScheme")
    var colorScheme: ColorScheme {
        set {
            let storage = BDStorableValueSystemStorage.userDefaults.object
            storage.setValue(newValue.rawValue, forKey: colorSchemeKey)
        }
        get {
            let storage = BDStorableValueSystemStorage.userDefaults.object
            let defaultValue = ColorScheme.system
            let rawValue = storage.value(forKey: colorSchemeKey) as? Int ?? defaultValue.rawValue
            return ColorScheme(rawValue: rawValue) ?? defaultValue
        }
    }
    
    @BDStoredValue(in: .userDefaults, key: key("noteCardSortOptionAscending"), default: true)
    var noteCardSortOptionAscending: Bool
    
    let noteCardSortOptionKey = key("noteCardSortOption")
    var noteCardSortOption: NoteCardSortField {
        set {
            let storage = BDStorableValueSystemStorage.userDefaults.object
            storage.setValue(newValue.rawValue, forKey: noteCardSortOptionKey)
        }
        get {
            let storage = BDStorableValueSystemStorage.userDefaults.object
            let defaultValue = NoteCardSortField.translation
            let rawValue = storage.value(forKey: noteCardSortOptionKey) as? Int ?? defaultValue.rawValue
            return NoteCardSortField(rawValue: rawValue) ?? defaultValue
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
