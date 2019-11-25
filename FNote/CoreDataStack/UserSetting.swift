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
    
    static private(set) var current = UserSetting.load()
    
    static let kSavedData = "kUserSetting.iCloudSavedData"
    
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
        let iCloudStore = NSUbiquitousKeyValueStore.default
        iCloudStore.set(data, forKey: Self.kSavedData)
        iCloudStore.synchronize()
    }
    
    func applyColorScheme() {
        let interface = colorScheme.userInterfaceStyle
        let windows = UIApplication.shared.windows
        for window in windows where window.overrideUserInterfaceStyle != interface {
            window.overrideUserInterfaceStyle = interface
        }
    }
    
    func update(with setting: UserSetting) {
        objectWillChange.send()
        colorScheme = setting.colorScheme
        username = setting.username
    }
}


// MARK: - Setup

extension UserSetting {
    
    /// Setup setting publishers.
    private func setupPublishers() {
        let colorCancellable = $colorScheme.eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { _ in self.applyColorScheme() }
        cancellables.append(colorCancellable)
    }
    
    func listenToRemoteChange() {
        let center = NotificationCenter.default
        let notification = NSUbiquitousKeyValueStore.didChangeExternallyNotification
        let action = #selector(handleRemoteChange)
        center.addObserver(self, selector: action, name: notification, object: nil)
    }
    
    @objc private func handleRemoteChange() {
        let updated = UserSetting.load()
        let current = UserSetting.current
        current.update(with: updated)
    }
}


extension UserSetting {
    
    static private func load() -> UserSetting {
        let decoder = JSONDecoder()
        let iCloudStore = NSUbiquitousKeyValueStore.default
        let savedData = iCloudStore.object(forKey: Self.kSavedData) as? Data
        
        if let data = savedData, let setting = try? decoder.decode(UserSetting.self, from: data) {
            return setting
        } else {
            let setting = UserSetting()
            setting.username = randomUsername()
            setting.save()
            return setting
        }
    }
    
    static private func randomUsername() -> String {
        let number = Int.random(in: 1...999)
        return String(format: "User%03d", number)
    }
    
    static let sample = UserSetting()
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
            case .system: return "Adapt System Appearance"
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
