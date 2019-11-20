//
//  UserSetting.swift
//  FNote
//
//  Created by Dara Beng on 11/13/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import UIKit
import Combine


class UserSetting: ObservableObject, Codable {
    
    static let current = UserSetting.load()
    
    @Published var username = ""
    
    @Published var colorScheme = ColorScheme.system
        
    private var cancellables = [AnyCancellable]()
    
    
    // MARK: Constructor & Codable
    
    private init() {
        setupPublishers()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        colorScheme = try container.decode(ColorScheme.self, forKey: .colorScheme)
        username = try container.decode(String.self, forKey: .username)
        setupPublishers()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(colorScheme, forKey: .colorScheme)
        try container.encode(username, forKey: .username)
    }
    
    
    // MARK: Method
    
    /// Save the settings.
    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        AppCache.userSettingData = data
    }
    
    func applyColorScheme() {
        let interface = colorScheme.userInterfaceStyle
        let windows = UIApplication.shared.windows
        windows.forEach({ $0.overrideUserInterfaceStyle = interface })
    }
    
    // MARK: Publisher
    
    /// Setup setting publishers.
    private func setupPublishers() {
        let color = $colorScheme.eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { _ in self.applyColorScheme() }
        
        cancellables.append(color)
    }
}


extension UserSetting {
    
    static private func load() -> UserSetting {
        let decoder = JSONDecoder()
        let data = AppCache.userSettingData
        
        if let data = data, let setting = try? decoder.decode(UserSetting.self, from: data) {
            return setting
        }
        
        let setting = UserSetting()
        setting.username = randomUsername()
        setting.save()
        return setting
    }
    
    static private func randomUsername() -> String {
        let number = Int.random(in: 1...999)
        return String(format: "User%03d", number)
    }
}


extension UserSetting {
    
    enum CodingKeys: CodingKey {
        case colorScheme
        case username
    }
    
    enum ColorScheme: Int, Codable, CaseIterable {
        case system
        case alwaysLight
        case alwaysDark
        
        
        var title: String {
            switch self {
            case .system: return "System"
            case .alwaysLight: return "Always Light"
            case .alwaysDark: return "Always Dark"
            }
        }
        
        var userInterfaceStyle: UIUserInterfaceStyle {
            switch self {
            case .system: return .unspecified
            case .alwaysLight: return .light
            case .alwaysDark: return .dark
            }
        }
    }
}
