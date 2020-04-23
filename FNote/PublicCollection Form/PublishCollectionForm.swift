//
//  PublishCollectionForm.swift
//  FNote
//
//  Created by Dara Beng on 3/12/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit
import BDSwiftility


struct PublishCollectionForm: View {
    
    @ObservedObject var viewModel: PublishCollectionFormModel
    
    @State private var sheet = BDPresentationItem<Sheet>()
    @State private var alert: Alert?
    @State private var presentAlert = false
    
    @State private var textFieldModel = BDModalTextFieldModel()
    @State private var languageTextFieldModel = BDModalTextFieldModel()
    @State private var filteredLanguages: [Language] = []
    
    @State private var textViewModel = BDModalTextViewModel()
    
    let collectionViewModel = NoteCardCollectionCollectionViewModel()
    
    
    var body: some View {
        NavigationView {
            PublishCollectionViewControllerWrapper(viewModel: viewModel, onRowSelected: handleRowSelected)
                .opacity(viewModel.author.isValid ? 1 : 0.4)
                .disabled(viewModel.author.isValid == false)
                .navigationBarTitle("Publish Collection", displayMode: .inline)
                .navigationBarItems(leading: cancelNavButton, trailing: errorNavButton)
                .edgesIgnoringSafeArea(.bottom)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet.current, content: presentationSheet)
        .alert(isPresented: $presentAlert, content: { self.alert! })
        .onAppear(perform: setupOnAppear)
    }
}


// MARK: - Setup

extension PublishCollectionForm {
    
    func setupOnAppear() {
    }
    
    func handleRowSelected(kind: PublishCollectionViewController.Row) {
        viewModel.onRowSelected?(kind)
        switch kind {
        case .collection: beginSelectCollection()
        case .collectionName: beginEditCollectionName()
        case .collectionDescription: beginEditCollectionDescription()
        case .collectionTag: beginEditCollectionTags()
        case .collectionPrimaryLanguage: beginSelectPrimaryLanguage()
        case .collectionSecondaryLanguage: beginSelectSecondaryLanguage()
        case .publishAction: publishCollection()
        case .includeNote, .authorName: break
        }
    }
}


extension PublishCollectionForm {
    
    var cancelNavButton: some View {
        Button("Cancel", action: viewModel.onCancel ?? {})
    }
    
    var errorNavButton: some View {
        let action = { self.presentAlert = true }
        let warning = Button(action: action) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .imageScale(.large)
                .opacity(alert == nil ? 0 : 1)
        }
        .disabled(alert == nil)
        
        let fill = Button("Fill") {
            let randomNumber = Int.random(in: 4...49)
            self.viewModel.publishCollectionName = "CName \(randomNumber)"
            self.viewModel.publishTags = ["\(randomNumber)", "\(randomNumber + 1)"]
            self.viewModel.publishDescription = "Description \(randomNumber)"
            self.viewModel.publishPrimaryLanguage = Language.availableISO639s.randomElement()
            self.viewModel.publishSecondaryLanguage = Language.availableISO639s.randomElement()
        }
        
        return HStack(spacing: 8) {
            warning
            fill
        }
    }
}


// MARK: - Sheet

extension PublishCollectionForm {
    
    enum Sheet: BDPresentationSheetItem {
        case collectionName
        case publishCollection
        case publishDescription
        case publishTags
        case publishLanguages
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .collectionName, .publishTags:
            return BDModalTextField(viewModel: $textFieldModel)
                .eraseToAnyView()
            
        case .publishLanguages:
            return BDModalTextField(viewModel: $languageTextFieldModel)
                .onReceive(languageTextFieldModel.text.publisher.count(), perform: { _ in
                    self.filterLanguageForLanguageTextFieldModel()
                })
                .eraseToAnyView()
        
        case .publishDescription:
            return BDModalTextView(viewModel: $textViewModel)
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
            self.viewModel.publishCollectionName = self.textFieldModel.text.trimmedComma()
            self.textFieldModel.isFirstResponder = false
            self.sheet.dismiss()
        }
    }
    
    /// Edit publish collection's description.
    func beginEditCollectionDescription() {
        textViewModel.title = "Brief Description"
        textViewModel.text = viewModel.publishDescription
        textViewModel.characterLimit = viewModel.publishDescriptionLimit
        textViewModel.characterLimitColor = .secondary
        textViewModel.isFirstResponder = true
        sheet.present(.publishDescription)
        
        textViewModel.onCommit = {
            self.viewModel.publishDescription = self.textViewModel.text.trimmed()
            self.textViewModel.isFirstResponder = false
            self.sheet.dismiss()
        }
    }
    
    /// Edit publish collection's tags.
    func beginEditCollectionTags() {
        let maxTags = viewModel.publishTagsLimit
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
        
        textFieldModel.configure = { textField in
            textField.autocapitalizationType = .none
        }
        
        // add tag action
        textFieldModel.onReturnKey = {
            let newToken = self.textFieldModel.text.trimmedComma().lowercased()
            
            if newToken.isEmpty {
                self.textFieldModel.text = ""
                return
            }
            
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
    static let viewModel: PublishCollectionFormModel = {
        let user = PublicUser(userID: "someID0409", username: "DLan", about: "This is a test user.")
        let model = PublishCollectionFormModel(user: user)
        return model
    }()
    static var previews: some View {
        Group {
            PublishCollectionForm(viewModel: viewModel)
                .colorScheme(.light)
                .accentColor(.appAccent)
            PublishCollectionForm(viewModel: viewModel)
                .colorScheme(.dark)
                .accentColor(.appAccent)
        }
    }
}





