//
//  AppSetting.swift
//  FNote
//
//  Created by Dara Beng on 11/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit


class AppSetting: ObservableObject, Codable {
    
    static let current = AppSetting.load()
    
    weak var keyWindow: UIWindow?
    
    @Published var colorScheme = ColorScheme.automatic {
        didSet { applyColorScheme() }
    }
    
    
    // MARK: Method
    
    /// Save the settings.
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.saveKey)
        }
    }
    
    func setKeyWindow(_ window: UIWindow) {
        self.keyWindow = window
    }
    
    func applyColorScheme() {
        guard let window = keyWindow else { return }
        switch colorScheme {
        case .automatic:
            window.overrideUserInterfaceStyle = .unspecified
        case .alwaysLight:
            window.overrideUserInterfaceStyle = .light
        case .alwaysDark:
            window.overrideUserInterfaceStyle = .dark
        }
    }
    
    
    // MARK: Decode & Encode
    
    private init() {}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        colorScheme = try container.decode(ColorScheme.self, forKey: .colorScheme)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(colorScheme, forKey: .colorScheme)
    }
    
    enum CodingKeys: CodingKey {
        case colorScheme
    }
}


extension AppSetting {
    
    static let saveKey = "AppSetting.saveKey"
    
    static func load() -> AppSetting {
        let decoder = JSONDecoder()
        let data = UserDefaults.standard.data(forKey: Self.saveKey)
        if let data = data, let setting = try? decoder.decode(AppSetting.self, from: data) {
            return setting
        }
        return AppSetting()
    }
}


extension AppSetting {
    
    enum ColorScheme: Int, Codable, CaseIterable {
        case automatic
        case alwaysLight
        case alwaysDark
        
        
        var title: String {
            switch self {
            case .automatic: return "Automatic"
            case .alwaysLight: return "Always Light"
            case .alwaysDark: return "Always Dark"
            }
        }
    }
}
