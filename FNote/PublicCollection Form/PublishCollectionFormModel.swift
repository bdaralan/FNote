//
//  PublishCollectionFormModel.swift
//  FNote
//
//  Created by Dara Beng on 3/14/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


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
    
    var publishState: PublishState = .preparing {
        didSet { onPublishStateChanged?(publishState) }
    }
    
    let publicCardsRequired = 9
    let publishTagsLimit = 4
    let publishDescriptionLimit = 249
    
    var onCommit: (() -> Void)?
    
    var onCancel: (() -> Void)?
        
    var onPublishStateChanged: ((PublishState) -> Void)?
    
    var onRowSelected: ((PublishCollectionViewController.Row) -> Void)?
    
    
    init(user: PublicUser) {
        self.author = user
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
    
    var uiPublishCollectionNamePlaceholder: String {
        publishCollectionName.isEmpty ? "publish name" : publishCollectionName
    }
    
    var uiAuthorName: String {
        author.isValid ? author.username : "required"
    }
    
    var uiCollectionName: String {
        publishCollection?.name ?? "required"
    }
    
    var uiCollectionNameColor: UIColor {
        publishCollection == nil ? .secondaryLabel : .label
    }
    
    var uiCollectionPublishName: String {
        publishCollectionName.isEmpty ? "required" : publishCollectionName
    }
    
    var uiCollectionPublishNameColor: UIColor {
        publishCollectionName.isEmpty ? .secondaryLabel : .label
    }
    
    var uiCollectionCardsCount: String {
        let count = publishCollection?.noteCards.count ?? 0
        if count < publicCardsRequired {
            return "minimum of \(publicCardsRequired) cards"
        }
        return String(quantity: count, singular: "CARD", plural: "CARDS")
    }
    
    var uiCollectionDescription: String {
        publishDescription.isEmpty ? "required" : publishDescription
    }
    
    var uiCollectionDescriptionColor: UIColor {
        if publishDescription.isEmpty {
            return .secondaryLabel
        }
        return publishDescription.count > publishDescriptionLimit ? .red : .label
    }
    
    var uiCollectionTags: String {
        publishTags.isEmpty ? "required" : publishTags.joined(separator: ", ")
    }
    
    var uiCollectionTagsColor: UIColor {
        publishTags.isEmpty ? .secondaryLabel : .label
    }
    
    var uiCollectionPrimaryLanguage: String {
        publishPrimaryLanguage?.localized ?? "required"
    }
    
    var uiCollectionPrimaryLanguageColor: UIColor {
        publishPrimaryLanguage == nil ? .secondaryLabel : .label
    }
    
    var uiCollectionSecondaryLanguage: String {
        publishSecondaryLanguage?.localized ?? "required"
    }
    
    var uiCollectionSecondaryLanguageColor: UIColor {
        publishSecondaryLanguage == nil ? .secondaryLabel : .label
    }
}
