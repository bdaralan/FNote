//
//  PublishCollectionForm.swift
//  FNote
//
//  Created by Dara Beng on 3/12/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct PublishCollectionForm: View {
    
    @ObservedObject var viewModel: PublishCollectionFormModel
    
    let publishTagsLimit = 4
    
    @State private var sheet: Sheet?
    @State private var showLanguagePicker = false
    @State private var textFieldModel = ModalTextFieldModel()
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
        .sheet(item: $sheet, content: presentationSheet)
        .overlay(collectionLanguagePicker)
    }
}


// MARK: - Setup

extension PublishCollectionForm {
    
    func handleRowSelected(kind: PublishFormRowKind) {
        viewModel.onRowSelected?(kind)
        switch kind {
        case .authorName: beginEditAuthorName()
        case .collection: beginSelectCollection()
        case .collectionName: beginEditCollectionName()
        case .collectionDescription: beginEditCollectionDescription()
        case .collectionTag: beginEditCollectionTags()
        case .collectionLanguage: beginSelectCollectionLanguages()
        case .publishAction: publishCollection()
        case .includeNote: break
        }
    }
}


// MARK: - Sheet

extension PublishCollectionForm {
    
    enum Sheet: Identifiable {
        var id: Self { self }
        case authorName
        case collectionName
        case publishCollection
        case publishDescription
        case publishTags
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .authorName, .collectionName, .publishTags:
            return ModalTextField(viewModel: $textFieldModel)
                .eraseToAnyView()
        
        case .publishDescription:
            return ModalTextView(viewModel: $collectionDescriptionTextViewModel)
                .eraseToAnyView()
            
        case .publishCollection:
            let cancel = Button("Cancel", action: { self.sheet = nil })
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
        textFieldModel.placeholder = viewModel.authorName
        textFieldModel.prompt = "name that appears on all published collections (A-Z, 0-9, -, _)"
        textFieldModel.isFirstResponder = true
        sheet = .authorName
        
        textFieldModel.onCancel = {
            self.textFieldModel.isFirstResponder = false
            self.sheet = nil
        }
        
        textFieldModel.onReturnKey = {
            self.viewModel.authorName = self.textFieldModel.text.trimmedUsername()
            self.textFieldModel.isFirstResponder = false
            self.sheet = nil
        }
    }
}


// MARK: - Collection

extension PublishCollectionForm {
    
    /// Choose a collection to publish.
    func beginSelectCollection() {
        // test code
        var collections = [NoteCardCollection]()
        for _ in 1...10 {
            let collection = NoteCardCollection(context: .sample)
            collection.name = "Publish Collection \(Int.random(in: 1...100))"
            for i in 4...Int.random(in: 9...19) {
                let card = NoteCard(context: .sample)
                let number = i + 1
                card.native = "native \(number)"
                card.translation = "translation \(number)"
                card.note = "note \(number)"
                card.formality = NoteCard.Formality.allCases.randomElement()!
                card.collection = collection
            }
            collections.append(collection)
        }
        viewModel.selectableCollections = collections
        
        // real code
        collectionViewModel.collections = viewModel.selectableCollections
        collectionViewModel.disableCollectionIDs = []
        
        let disableCollections = viewModel.selectableCollections.filter({ $0.noteCards.count < 9 })
        for collection in disableCollections {
            collectionViewModel.disableCollectionIDs.insert(collection.uuid)
        }
        
        if let collection = viewModel.publishCollection {
            collectionViewModel.disableCollectionIDs.insert(collection.uuid)
        }
        
        collectionViewModel.onCollectionSelected = { collection in
            self.viewModel.publishCollection = collection
            self.sheet = nil
        }
        
        sheet = .publishCollection
    }
}


// MARK: - Publish Detail

extension PublishCollectionForm {
    
    func beginEditCollectionName() {
        textFieldModel = .init()
        textFieldModel.title = "Collection Name"
        textFieldModel.text = viewModel.publishCollectionName
        textFieldModel.placeholder = viewModel.publishCollectionName
        textFieldModel.prompt = "publish name"
        textFieldModel.isFirstResponder = true
        sheet = .collectionName
        
        textFieldModel.onCancel = {
            self.textFieldModel.isFirstResponder = false
            self.sheet = nil
        }
        
        textFieldModel.onReturnKey = {
            self.viewModel.publishCollectionName = self.textFieldModel.text.trimmed()
            self.textFieldModel.isFirstResponder = false
            self.sheet = nil
        }
    }
    
    /// Edit publish collection's description.
    func beginEditCollectionDescription() {
        collectionDescriptionTextViewModel.title = "Brief Description"
        collectionDescriptionTextViewModel.text = viewModel.publishDescription
        collectionDescriptionTextViewModel.disableEditing = false
        collectionDescriptionTextViewModel.renderMarkdown = false
        collectionDescriptionTextViewModel.isFirstResponder = true
        sheet = .publishDescription
        
        collectionDescriptionTextViewModel.onCommit = {
            self.viewModel.publishDescription = self.collectionDescriptionTextViewModel.text
            self.collectionDescriptionTextViewModel.isFirstResponder = false
            self.sheet = nil
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
        textFieldModel.tokens = viewModel.publishTags
        textFieldModel.isFirstResponder = true
        textFieldModel.returnKeyType = .default
        setDefaultPrompt()
        sheet = .publishTags
        
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
            self.sheet = nil
        }
    }
}


// MARK: - Publish Option

extension PublishCollectionForm {
    
    
}


// MARK: - Language

extension PublishCollectionForm {
    
    var collectionLanguagePicker: some View {
        let commitAction = commitSelectCollectionLanguages
        
        let header = HStack(spacing: 8) {
            Text("Indicate Native  ➜  Translation")
                .fontWeight(.semibold)
                .lineLimit(1)
            Spacer()
            Button(action: commitAction) {
                Text("Done").bold()
            }
        }
        
        let picker = LanguagePickerWrapper(
            primary: $viewModel.publishPrimaryLanguage,
            secondary: $viewModel.publishSecondaryLanguage
        )
        
        return InputOverlayView(isPresented: $showLanguagePicker, onTouchOutside: commitAction) {
            VStack(spacing: 0) {
                header.padding(.all)
                Divider()
                picker
            }
        }
    }
    
    /// Choose publish collection's languages.
    func beginSelectCollectionLanguages() {
        showLanguagePicker = true
    }
    
    func commitSelectCollectionLanguages() {
        showLanguagePicker = false
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





