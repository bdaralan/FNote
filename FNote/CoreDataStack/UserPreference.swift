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
    
    weak var window: UIWindow?
    
    // MARK: iCloud
    
    @UserStoredValue(in: .iCloud, key: "kUserPreference.colorScheme", defaultValue: ColorScheme.system.rawValue)
    var colorScheme: Int
        
    @UserStoredValue(in: .iCloud, key: "kUserPreference.useMarkdown", defaultValue: true)
    var useMarkdown: Bool
    
    @UserStoredValue(in: .iCloud, key: "kUserPreference.useMarkdownSoftBreak", defaultValue: false)
    var useMarkdownSoftBreak: Bool
    
    
    // MARK: User Defaults
    
    @UserStoredValue(in: .iCloud, key: "kUserPreference.noteCardSortOptionAscending", defaultValue: true)
    var noteCardSortOptionAscending: Bool
    
    let noteCardSortOptionKey = "kUserPreference.noteCardSortOption"
    var noteCardSortOption: NoteCardSortOption {
        set {
            objectWillChange.send()
            UserStoredValue.Storage.iCloud.setValue(newValue.rawValue, forKey: noteCardSortOptionKey)
        }
        get {
            let storage = UserStoredValue<Int>.Storage.iCloud
            let defaultValue = NoteCardSortOption.translation.rawValue
            let rawValue = storage.value(forKey: noteCardSortOptionKey, defaultValue: defaultValue)
            return NoteCardSortOption(rawValue: rawValue) ?? .translation
        }
    }
    
    
    private init() {}
    
    
    func applyColorScheme() {
        guard let window = window else { return }
        setColorScheme(for: window)
    }
    
    func setColorScheme(for window: UIWindow) {
        self.window = window
        let preferredStyle = ColorScheme(rawValue: colorScheme)?.userInterfaceStyle ?? .unspecified
        window.overrideUserInterfaceStyle = preferredStyle
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
