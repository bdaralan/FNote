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
    
    // MARK: Key
    
    enum Keys: BDPersistKey {
        var prefix: String { "kUserPreference." }
        case useMarkdown
        case useMarkdownSoftBreak
        case showGeneralKeyboardUsage
        case colorScheme
        case noteCardSortOptionAscending
        case noteCardSortOption
    }
    
    
    // MARK: Ubiquitous
        
    @BDPersist(in: .ubiquitousStore, key: Keys.useMarkdown, default: true)
    var useMarkdown: Bool
    
    @BDPersist(in: .ubiquitousStore, key: Keys.useMarkdownSoftBreak, default: true)
    var useMarkdownSoftBreak: Bool
    
    @BDPersist(in: .ubiquitousStore, key: Keys.showGeneralKeyboardUsage, default: true)
    var showGeneralKeyboardUsage: Bool
    
    
    // MARK: UserDefaults
    
    var colorScheme: ColorScheme {
        set {
            let store = BDSystemPersistentStore.userDefaults.store
            store.setValue(newValue.rawValue, forKey: Keys.colorScheme.prefixedKey)
        }
        get {
            let store = BDSystemPersistentStore.userDefaults.store
            let defaultValue = ColorScheme.system
            let rawValue = store.getValue(forKey: Keys.colorScheme) as? Int ?? defaultValue.rawValue
            return ColorScheme(rawValue: rawValue) ?? defaultValue
        }
    }
    
    @BDPersist(in: .userDefaults, key: Keys.noteCardSortOptionAscending, default: true)
    var noteCardSortOptionAscending: Bool
    
    var noteCardSortOption: NoteCard.SearchField {
        set {
            let store = BDSystemPersistentStore.userDefaults.store
            store.setValue(newValue.rawValue, forKey: Keys.noteCardSortOption)
        }
        get {
            let store = BDSystemPersistentStore.userDefaults.store
            let defaultValue = NoteCard.SearchField.translation.rawValue
            let rawValue = store.getValue(forKey: Keys.noteCardSortOption) as? String ?? defaultValue
            return NoteCard.SearchField(rawValue: rawValue)!
        }
    }
    
    
    // MARK: Constructor
    
    fileprivate init() {}
    
    
    // MARK: Method
    
    func applyColorScheme() {
        for window in UIApplication.shared.windows {
            window.overrideUserInterfaceStyle = colorScheme.userInterfaceStyle
        }
    }
}


// MARK: - Color Scheme

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


// MARK: - App State

extension AppState {
    
    func getPreference() -> UserPreference {
        UserPreference()
    }
}


// MARK: - Sample

extension UserPreference {
    
    static var sample: UserPreference {
        UserPreference()
    }
}
