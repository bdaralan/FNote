//
//  PublishCollectionForm.swift
//  FNote
//
//  Created by Dara Beng on 3/12/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit


struct PublishCollectionForm: View {
    
    @ObservedObject var viewModel: PublishCollectionFormModel
    
    let publishTagsLimit = 4
    
    @State private var sheet = PresentingSheet<Sheet>()
    
    @State private var textFieldModel = BDModalTextFieldModel()
    @State private var languageTextFieldModel = BDModalTextFieldModel()
    @State private var filteredLanguages: [Language] = []
    
    @State private var collectionDescriptionTextViewModel = ModalTextViewModel()
    
    let collectionViewModel = NoteCardCollectionCollectionViewModel()
    
    
    var body: some View {
        NavigationView {
            PublishCollectionViewControllerWrapper(viewModel: viewModel, onRowSelected: handleRowSelected)
                .navigationBarTitle("Publish Collection", displayMode: .inline)
                .navigationBarItems(leading: Button("Cancel", action: viewModel.onCancel ?? {}) )
                .edgesIgnoringSafeArea(.bottom)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet.presenting, content: presentationSheet)
    }
}


// MARK: - Setup

extension PublishCollectionForm {
    
    func handleRowSelected(kind: PublishFormSection.Row) {
        viewModel.onRowSelected?(kind)
        switch kind {
        case .authorName: beginEditAuthorName()
        case .collection: beginSelectCollection()
        case .collectionName: beginEditCollectionName()
        case .collectionDescription: beginEditCollectionDescription()
        case .collectionTag: beginEditCollectionTags()
        case .collectionPrimaryLanguage: beginSelectPrimaryLanguage()
        case .collectionSecondaryLanguage: beginSelectSecondaryLanguage()
        case .publishAction: publishCollection()
        case .includeNote: break
        }
    }
}


// MARK: - Sheet

extension PublishCollectionForm {
    
    enum Sheet: PresentingSheetEnum {
        case authorName
        case collectionName
        case publishCollection
        case publishDescription
        case publishTags
        case publishLanguages
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .authorName, .collectionName, .publishTags:
            return BDModalTextField(viewModel: $textFieldModel)
                .eraseToAnyView()
            
        case .publishLanguages:
            return BDModalTextField(viewModel: $languageTextFieldModel)
                .onReceive(languageTextFieldModel.text.publisher.count(), perform: { _ in
                    self.filterLanguageForLanguageTextFieldModel()
                })
                .eraseToAnyView()
        
        case .publishDescription:
            return ModalTextView(viewModel: $collectionDescriptionTextViewModel)
                .eraseToAnyView()
            
        case .publishCollection:
            let cancel = Button("Cancel", action: { self.sheet.dismiss() })
            return NavigationView {
                CollectionViewWrapper(viewModel: collectionViewModel)
                    .navigationBarTitle("Select Collection", displayMode: .inline)
                    .navigationBarItems(leading: cancel)
                    .edgesIgnoringSafeArea(.all)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .eraseToAnyView()
        }
    }
}


// MARK: - Author

extension PublishCollectionForm {
    
    func beginEditAuthorName() {
        textFieldModel = .init()
        textFieldModel.title = "Author Name"
        textFieldModel.text = viewModel.authorName
        textFieldModel.placeholder = viewModel.uiAuthorNamePlaceholder
        textFieldModel.prompt = "The name that appears on all published collections (A-Z, 0-9, -, _)"
        textFieldModel.isFirstResponder = true
        sheet.present(.authorName)
        
        textFieldModel.onCancel = {
            self.textFieldModel.isFirstResponder = false
            self.sheet.dismiss()
        }
        
        textFieldModel.onReturnKey = {
            self.viewModel.authorName = self.textFieldModel.text.trimmedUsername()
            self.textFieldModel.isFirstResponder = false
            self.sheet.dismiss()
        }
    }
}


// MARK: - Collection

extension PublishCollectionForm {
    
    /// Choose a collection to publish.
    func beginSelectCollection() {
        collectionViewModel.collections = viewModel.selectableCollections
        collectionViewModel.disabledCollectionIDs = []
        
        let disableCollections = viewModel.selectableCollections.filter({ $0.noteCards.count < 9 })
        for collection in disableCollections {
            collectionViewModel.disabledCollectionIDs.insert(collection.uuid)
        }
        
        if let collection = viewModel.publishCollection {
            collectionViewModel.disabledCollectionIDs.insert(collection.uuid)
        }
        
        collectionViewModel.onCollectionSelected = { collection in
            self.viewModel.publishCollection = collection
            self.sheet.dismiss()
        }
        
        sheet.present(.publishCollection)
    }
}


// MARK: - Publish Detail

extension PublishCollectionForm {
    
    func beginEditCollectionName() {
        textFieldModel = .init()
        textFieldModel.title = "Collection Name"
        textFieldModel.text = viewModel.publishCollectionName
        textFieldModel.placeholder = viewModel.uiPublishCollectionNamePlaceholder
        textFieldModel.prompt = "The collection's publish name"
        textFieldModel.isFirstResponder = true
        sheet.present(.collectionName)
        
        textFieldModel.onCancel = {
            self.textFieldModel.isFirstResponder = false
            self.sheet.dismiss()
        }
        
        textFieldModel.onReturnKey = {
            self.viewModel.publishCollectionName = self.textFieldModel.text.trimmed()
            self.textFieldModel.isFirstResponder = false
            self.sheet.dismiss()
        }
    }
    
    /// Edit publish collection's description.
    func beginEditCollectionDescription() {
        collectionDescriptionTextViewModel.title = "Brief Description"
        collectionDescriptionTextViewModel.text = viewModel.publishDescription
        collectionDescriptionTextViewModel.disableEditing = false
        collectionDescriptionTextViewModel.renderMarkdown = false
        collectionDescriptionTextViewModel.isFirstResponder = true
        sheet.present(.publishDescription)
        
        collectionDescriptionTextViewModel.onCommit = {
            self.viewModel.publishDescription = self.collectionDescriptionTextViewModel.text
            self.collectionDescriptionTextViewModel.isFirstResponder = false
            self.sheet.dismiss()
        }
    }
    
    /// Edit publish collection's tags.
    func beginEditCollectionTags() {
        let maxTags = self.publishTagsLimit
        let setDefaultPrompt = {
            let count = self.textFieldModel.tokens.count
            self.textFieldModel.prompt = "collection's tags \(count)/\(maxTags)"
            self.textFieldModel.promptColor = nil
        }
        
        textFieldModel = .init()
        textFieldModel.title = "Tags"
        textFieldModel.placeholder = "tag"
        textFieldModel.tokens = viewModel.publishTags
        textFieldModel.showClearTokenIndicator = true
        textFieldModel.isFirstResponder = true
        textFieldModel.returnKeyType = .default
        setDefaultPrompt()
        sheet.present(.publishTags)
        
        // remove tag action
        textFieldModel.onTokenSelected = { token in
            self.textFieldModel.tokens.removeAll(where: { $0 == token })
            setDefaultPrompt()
        }
        
        // add tag action
        textFieldModel.onReturnKey = {
            let newToken = self.textFieldModel.text.trimmed().replacingOccurrences(of: ",", with: "")
            
            // check duplicate
            if self.textFieldModel.tokens.contains(newToken) {
                self.textFieldModel.prompt = "Duplicate tag"
                self.textFieldModel.promptColor = .red
                return
            }
            
            // check limit
            if self.textFieldModel.tokens.count == maxTags {
                self.textFieldModel.prompt = "Cannot have more than \(maxTags) tags 🥺"
                self.textFieldModel.promptColor = .orange
                return
            }
            
            // add tag
            self.textFieldModel.tokens.append(newToken)
            self.textFieldModel.text = ""
            setDefaultPrompt()
        }
        
        // commit tags action
        textFieldModel.onCommit = {
            self.viewModel.publishTags = self.textFieldModel.tokens
            self.sheet.dismiss()
        }
    }
}


// MARK: - Language

extension PublishCollectionForm {
    
    func beginSelectPrimaryLanguage() {
        languageTextFieldModel = .init()
        languageTextFieldModel.title = "Primary Language"
        languageTextFieldModel.placeholder = viewModel.publishPrimaryLanguage?.localized ?? "Search"
        languageTextFieldModel.prompt = "Select the language to learn"
        languageTextFieldModel.returnKeyType = .default
        
        languageTextFieldModel.onTokenSelected = { token in
            let language = self.filteredLanguages.first(where: { $0.localized == token })
            self.viewModel.publishPrimaryLanguage = language
            self.languageTextFieldModel.isFirstResponder = false
            self.sheet.dismiss()
        }
        
        languageTextFieldModel.onCancel = {
            self.languageTextFieldModel.isFirstResponder = false
            self.sheet.dismiss()
        }
        
        languageTextFieldModel.isFirstResponder = true
        sheet.present(.publishLanguages)
    }
    
    func beginSelectSecondaryLanguage() {
        languageTextFieldModel = .init()
        languageTextFieldModel.title = "Secondary Language"
        languageTextFieldModel.placeholder = viewModel.publishSecondaryLanguage?.localized ?? "Search"
        languageTextFieldModel.prompt = "Select the language used to translate"
        languageTextFieldModel.returnKeyType = .default
        
        languageTextFieldModel.onTokenSelected = { token in
            let language = self.filteredLanguages.first(where: { $0.localized == token })
            self.viewModel.publishSecondaryLanguage = language
            self.languageTextFieldModel.isFirstResponder = false
            self.sheet.dismiss()
        }
        
        languageTextFieldModel.onCancel = {
            self.languageTextFieldModel.isFirstResponder = false
            self.sheet.dismiss()
        }
        
        languageTextFieldModel.isFirstResponder = true
        sheet.present(.publishLanguages)
    }
    
    /// Filter languages for `languageTextFieldModel`'s tokens.
    func filterLanguageForLanguageTextFieldModel() {
        let text = languageTextFieldModel.text
        if text.isEmpty {
            filteredLanguages = Language.availableISO639s
        } else {
            filteredLanguages = Language.availableISO639s.filter { language in
                language.localized.range(of: text, options: .caseInsensitive) != nil
            }
        }
        languageTextFieldModel.tokens = filteredLanguages.map(\.localized)
    }
}


// MARK: - Publish

extension PublishCollectionForm {
    
    /// Commit publishing collection.
    func publishCollection() {
        viewModel.onCommit?()
    }
}


struct PublishCollectionForm_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PublishCollectionForm(viewModel: .init())
                .colorScheme(.light)
                .accentColor(.appAccent)
            PublishCollectionForm(viewModel: .init())
                .colorScheme(.dark)
                .accentColor(.appAccent)
        }
    }
}





