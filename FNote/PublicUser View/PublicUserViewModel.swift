//
//  PublicUserViewModel.swift
//  FNote
//
//  Created by Dara Beng on 4/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation


class PublicUserViewModel: ObservableObject {
    
    private(set) var user: PublicUser
    
    @Published var username: String
    
    @Published var userBio: String
    
    @Published var disableUserInteraction = false
    
    var onDone: (() -> Void)?
    
    var onUserUpdated: ((PublicUser) -> Void)?
    
    var onUserUpdateFailed: ((Error) -> Void)?
    
    var hasChanges: Bool {
        user.username != username || user.about != userBio
    }
    
    
    init(user: PublicUser) {
        self.user = user
        username = user.username
        userBio = user.about
    }
    
    
    func update(with user: PublicUser) {
        objectWillChange.send()
        self.user = user
        username = user.username
        userBio = user.about
    }
    
    
    /// Save local changes and upload the the database.
    func saveChanges() {
        let username = self.username.trimmedUsername()
        let userBio = self.userBio.trimmed()
                
        if user.userID.isEmpty {
            createInitialUser(username: username, userBio: userBio)
        } else {
            updateUser(username: username, userBio: userBio)
        }
    }
    
    private func createInitialUser(username: String, userBio: String) {
        let recordManager = PublicRecordManager.shared
        
        recordManager.createInitialPublicUserRecord(username: username, userBio: userBio) { result in
            switch result {
            case .success(let record):
                let user = PublicUser(record: record)
                AppCache.cacheUser(user)
                if AppCache.hasSetupUserUpdateCKSubscription == false {
                    recordManager.setupPublicUserUpdateSubscriptions(userID: user.userID) { result in
                        guard case .success = result else { return }
                        AppCache.hasSetupUserUpdateCKSubscription = true
                    }
                }
                
                DispatchQueue.main.async {
                    self.onUserUpdated?(user)
                }
            
            case .failure(let error):
                DispatchQueue.main.async {
                    self.onUserUpdateFailed?(error)
                }
            }
        }
    }
    
    private func updateUser(username: String, userBio: String) {
        let recordManager = PublicRecordManager.shared
        
        recordManager.fetchPublicUserRecord(desiredFields: []) { result in
            switch result {
            case .success(let record):
                var modifier = RecordModifier<PublicUser.RecordFields>(record: record)
                modifier[.username] = username
                modifier[.lowercasedUsername] = username.lowercased()
                modifier[.about] = userBio
                
                recordManager.save(record: record) { result in
                    DispatchQueue.main.async { [weak self] in
                        switch result {
                        case .success(let record):
                            let updatedUser = PublicUser(record: record)
                            self?.onUserUpdated?(updatedUser)
                        
                        case .failure(let error):
                            self?.onUserUpdateFailed?(error)
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.onUserUpdateFailed?(error)
                }
            }
        }
    }
}
