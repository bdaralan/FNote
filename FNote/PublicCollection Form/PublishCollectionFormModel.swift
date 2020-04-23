//
//  PublishCollectionFormModel.swift
//  FNote
//
//  Created by Dara Beng on 3/14/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation


class PublishCollectionFormModel: ObservableObject {
    
    var selectableCollections: [NoteCardCollection] = []
    
    @Published var author: PublicUser
    
    @Published var publishCollection: NoteCardCollection?
    
    @Published var publishCollectionName: String = ""
    
    @Published var publishDescription: String = ""
    
    @Published var publishTags: [String] = []
    
    @Published var publishPrimaryLanguage: Language?
    
    @Published var publishSecondaryLanguage: Language?
    
    @Published var includesNote = true
    
    @Published var commitTitle = "PUBLISH"
    
    private(set) var publishState: PublishState = .editing
    
    let publishTagsLimit = 4
    let publishDescriptionLimit = 250
    
    var onCommit: (() -> Void)?
    
    var onCancel: (() -> Void)?
        
    var onPublishStateChanged: ((PublishState) -> Void)?
    
    var onRowSelected: ((PublishCollectionViewController.Row) -> Void)?
    
    
    init(user: PublicUser) {
        self.author = user
    }
    
    func setPublishState(to state: PublishState) {
        publishState = state
        onPublishStateChanged?(state)
    }
    
    func validateInputs() {
        publishCollectionName = publishCollectionName.trimmed()
        publishDescription = String(publishDescription.prefix(publishDescriptionLimit)).trimmed()
        publishTags = publishTags.map({ $0.trimmedComma() })
    }
}


// MARK: UI Property

extension PublishCollectionFormModel {
    
    var hasValidInputs: Bool {
        return author.isValid
            && publishCollection != nil
            && !publishCollectionName.isEmptyOrWhiteSpaces()
            && !publishTags.isEmpty
            && isLanguagesValid
            && publishDescription.trimmed().count <= publishDescriptionLimit
    }
    
    var isLanguagesValid: Bool {
        publishPrimaryLanguage != nil && publishSecondaryLanguage != nil
    }
    
    var uiAuthorName: String {
        author.isValid ? author.username : "required"
    }
    
    var uiCollectionName: String {
        publishCollection?.name ?? "required"
    }
    
    var uiPublishCollectionNamePlaceholder: String {
        publishCollectionName.isEmpty ? "publish name" : publishCollectionName
    }
    
    var uiCollectionPublishName: String {
        publishCollectionName.isEmpty ? "required" : publishCollectionName
    }
    
    var uiCollectionCardsCount: String {
        let count = publishCollection?.noteCards.count ?? 0
        let unit = count == 1 ? "CARD" : "CARDS"
        return "\(count) \(unit)"
    }
    
    var uiCollectionDescription: String {
        publishDescription.isEmpty ? "required" : publishDescription
    }
    
    var uiCollectionTags: String {
        publishTags.isEmpty ? "required" : publishTags.joined(separator: ", ")
    }
    
    var uiCollectionPrimaryLanguage: String {
        publishPrimaryLanguage?.localized ?? "required"
    }
    
    var uiCollectionSecondaryLanguage: String {
        publishSecondaryLanguage?.localized ?? "required"
    }
}
