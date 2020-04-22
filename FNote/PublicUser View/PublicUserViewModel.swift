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
    
    
    func saveChanges() {
        let newUsername = username.trimmedUsername()
        let newBio = userBio.trimmed()
        
        let recordManager = PublicRecordManager.shared
        
        recordManager.fetchPublicUserRecord(desiredKeys: [.username, .about]) { result in
            switch result {
            case .success(let record):
                record[PublicUser.RecordKeys.username.stringValue] = newUsername
                record[PublicUser.RecordKeys.about.stringValue] = newBio
                
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
