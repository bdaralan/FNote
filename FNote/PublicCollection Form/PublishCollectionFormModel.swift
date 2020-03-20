//
//  PublishCollectionFormModel.swift
//  FNote
//
//  Created by Dara Beng on 3/14/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation


class PublishCollectionFormModel: ObservableObject {
    
    @Published var publishCollection: NoteCardCollection?
    
    @Published var authorName: String = ""
    
    @Published var publishCollectionName: String = ""
    
    @Published var publishDescription: String = ""
    
    @Published var publishTags: [String] = []
    
    @Published var publishPrimaryLanguage: String = ""
    
    @Published var publishSecondaryLanguage: String = ""
    
    @Published var includesNote = true
    
    @Published var commitTitle = "PUBLISH"
    
    private(set) var publishState: PublishState = .editing
    
    var onCommit: (() -> Void)?
    
    var onCancel: (() -> Void)?
    
    var onPublishStateChanged: ((PublishState) -> Void)?
    
    func setPublishState(to newValue: PublishState) {
        publishState = newValue
        onPublishStateChanged?(newValue)
    }
}


// MARK: UI Property

extension PublishCollectionFormModel {
    
    enum PublishState {
        case editing
        case submitting
        case published
        case rejected
    }
    
    var hasValidInputs: Bool {
        return publishCollection != nil
            && !authorName.isEmptyOrWhiteSpaces()
            && !publishCollectionName.isEmptyOrWhiteSpaces()
            && !publishDescription.isEmptyOrWhiteSpaces()
            && !publishTags.isEmpty
            && isLanguagesValid
        
    }
    
    var isLanguagesValid: Bool {
        return !publishPrimaryLanguage.isEmptyOrWhiteSpaces()
            && !publishSecondaryLanguage.isEmptyOrWhiteSpaces()
    }
    
    var uiAuthorName: String {
        authorName.isEmpty ? "author name" : authorName
    }
    
    var uiCollectionName: String {
        publishCollection?.name ?? "select a collection"
    }
    
    var uiCollectionPublishName: String {
        publishCollectionName.isEmpty ? "collection name" : publishCollectionName
    }
    
    var uiCollectionCardsCount: String {
        let count = publishCollection?.noteCards.count ?? 0
        let unit = count == 1 ? "CARD" : "CARDS"
        return "\(count) \(unit)"
    }
    
    var uiCollectionDescription: String {
        publishDescription.isEmpty ? "a brief description of the collection..." : publishDescription
    }
    
    var uiCollectionTags: String {
        publishTags.isEmpty ? "tags" : publishTags.joined(separator: ", ")
    }
    
    var uiLanguages: String {
        if publishPrimaryLanguage.isEmptyOrWhiteSpaces() && publishSecondaryLanguage.isEmptyOrWhiteSpaces() {
            return "languages"
        }
        return "\(publishPrimaryLanguage) – \(publishSecondaryLanguage)"
    }
}
