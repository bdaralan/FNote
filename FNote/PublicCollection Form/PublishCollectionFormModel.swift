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
    
    @Published var publishCollection: NoteCardCollection?
    
    @Published var authorName: String = ""
    
    @Published var publishCollectionName: String = ""
    
    @Published var publishDescription: String = ""
    
    @Published var publishTags: [String] = []
    
    @Published var publishPrimaryLanguage: Language?
    
    @Published var publishSecondaryLanguage: Language?
    
    @Published var includesNote = true
    
    @Published var commitTitle = "PUBLISH"
    
    private(set) var publishState: PublishFormPublishState = .editing
    
    var onCommit: (() -> Void)?
    
    var onCancel: (() -> Void)?
    
    var onPublishStateChanged: ((PublishFormPublishState) -> Void)?
    
    var onRowSelected: ((PublishFormSection.Row) -> Void)?
    
    func setPublishState(to newValue: PublishFormPublishState) {
        publishState = newValue
        onPublishStateChanged?(newValue)
    }
}


// MARK: UI Property

extension PublishCollectionFormModel {
    
    var hasValidInputs: Bool {
        return publishCollection != nil
            && !authorName.isEmptyOrWhiteSpaces()
            && !publishCollectionName.isEmptyOrWhiteSpaces()
            && !publishDescription.isEmptyOrWhiteSpaces()
            && !publishTags.isEmpty
            && isLanguagesValid
    }
    
    var isLanguagesValid: Bool {
        publishPrimaryLanguage != nil && publishSecondaryLanguage != nil
    }
    
    var uiAuthorName: String {
        authorName.isEmpty ? "required" : authorName
    }
    
    var uiAuthorNamePlaceholder: String {
        authorName.isEmpty ? "author" : authorName
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
