//
//  PublishCollectionForm.swift
//  FNote
//
//  Created by Dara Beng on 3/12/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct PublishCollectionForm: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var viewModel: PublishCollectionFormModel
    
    let publishAuthorHeader = "AUTHOR"
    let publishAuthorFooter = "This will be displayed on all published collections."
    let publishCollectionHeader = "COLLECTION TO PUBLISH"
    let publishCollectionDetailHeader = "PUBLISH DETAILS"
    let publishOptionHeader = "PUBLISH OPTIONS"
    
    let publishTagsLimit = 4
    
    @State private var sheet: Sheet?
    @State private var showLanguagePicker = false
    
    @State private var isAuthorTextFieldActive = false
    @State private var isCollectionNameTextFieldActive = false
    @State private var isCollectionDescriptionTextFieldActive = false
    
    @State private var collectionDescriptionTextViewModel = ModalTextViewModel()
    @State private var collectionTagTextFieldModel = ModalTextFieldModel()
    
    let collectionViewModel = NoteCardCollectionCollectionViewModel()
    
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    Group {
                        // MARK: Author
                        ScrollViewSection(header: publishAuthorHeader, footer: publishAuthorFooter) {
                            TextFieldWrapper(
                                isActive: $isAuthorTextFieldActive,
                                text: $viewModel.authorName,
                                placeholder: "author name",
                                onCommit: { self.isAuthorTextFieldActive = false },
                                configure: configureTextField
                            )
                            .modifier(InsetRowStyle())
                        }
                        
                        // MARK: Publish Collection
                        ScrollViewSection(header: publishCollectionHeader) {
                            HStack {
                                Text(viewModel.uiCollectionName)
                                    .foregroundColor(viewModel.publishCollection == nil ? .tertiaryLabel : .primary)
                                Spacer()
                                Text(viewModel.uiCollectionCardsCount)
                                    .foregroundColor(.secondary)
                                    .opacity(viewModel.publishCollection == nil ? 0 : 1)
                            }
                            .modifier(InsetRowStyle())
                            .onTapGesture(perform: beginSelectCollection)
                        }
                        
                        // MARK: - Publish Details
                        ScrollViewSection(header: publishCollectionDetailHeader) {
                            VStack(spacing: 5) {
                                TextFieldWrapper(
                                    isActive: $isCollectionNameTextFieldActive,
                                    text: $viewModel.publishCollectionName,
                                    placeholder: "collection name",
                                    onCommit: { self.isCollectionNameTextFieldActive = false },
                                    configure: configureTextField
                                )
                                    .modifier(InsetRowStyle())
                                
                                Text(viewModel.uiCollectionDescription)
                                    .padding(.top)
                                    .foregroundColor(viewModel.publishDescription.isEmpty ? .tertiaryLabel : .primary)
                                    .modifier(InsetRowStyle(height: 110, alignment: .topLeading))
                                    .onTapGesture(perform: beginEditCollectionDescription)
                                
                                Text(viewModel.uiCollectionTags)
                                    .foregroundColor(viewModel.publishTags.isEmpty ? .tertiaryLabel : .primary)
                                    .modifier(InsetRowStyle())
                                    .onTapGesture(perform: beginEditCollectionTags)
                                
                                Text(viewModel.uiCollectionLanguages)
                                    .foregroundColor(viewModel.isLanguagesValid ? .primary : .tertiaryLabel)
                                    .modifier(InsetRowStyle())
                                    .onTapGesture(perform: beginSelectCollectionLanguages)
                            }
                        }
                        
                        // MARK: Publish Options
                        ScrollViewSection(header: publishOptionHeader) {
                            Toggle(isOn: $viewModel.includesNote, label: { Text("Include Cards' Notes") })
                                .modifier(InsetRowStyle())
                        }
                    }
                    
                    // MARK: Publish Button
                    VStack {
                        Button(action: publishCollection) {
                            Text(viewModel.commitTitle)
                                .font(Font.body.weight(.black))
                                .frame(maxWidth: .infinity)
                                .foregroundColor(colorScheme == .light ? .black : .white)
                                .modifier(InsetRowStyle(height: 60, borderColor: .primary, borderWidth: 2))
                        }
                        .disabled(!viewModel.hasValidInputs)
                        .opacity(viewModel.hasValidInputs ? 1 : 0.4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
            .navigationBarTitle("Publish Collection", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel", action: viewModel.onCancel ?? {}) )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet, content: presentationSheet)
        .overlay(inputLanguagePicker, alignment: .center)
    }
}


// MARK: - Text Field

extension PublishCollectionForm {
    
    func configureTextField(_ textField: UITextField) {
        textField.font = .preferredFont(forTextStyle: .body)
    }
    
    var inputLanguagePicker: some View {
        InputOverlayView(isPresented: $showLanguagePicker) {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Text("Native & Translation Languages")
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Spacer()
                    Button(action: commitSelectCollectionLanguage) {
                        Text("Done").bold()
                    }
                }
                .padding(.all)
                Divider()
                LanguagePickerWrapper(
                    primary: $viewModel.publishPrimaryLanguage,
                    secondary: $viewModel.publishSecondaryLanguage
                )
            }
        }
    }
}


// MARK: - Action and Handler

extension PublishCollectionForm {
    
    /// Commit publishing collection.
    func publishCollection() {
        viewModel.onCommit?()
    }
    
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
    
    /// Choose publish collection's languages.
    func beginSelectCollectionLanguages() {
        showLanguagePicker = true
    }
    
    func commitSelectCollectionLanguage() {
        showLanguagePicker = false
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
        let initialPrompt = "Can add up to \(maxTags) tags"
        
        collectionTagTextFieldModel = .init()
        collectionTagTextFieldModel.title = "Tags"
        collectionTagTextFieldModel.prompt = initialPrompt
        collectionTagTextFieldModel.tokens = viewModel.publishTags
        collectionTagTextFieldModel.isFirstResponder = true
        collectionTagTextFieldModel.returnKeyType = .default
        sheet = .publishTags
        
        // remove tag action
        collectionTagTextFieldModel.onTokenSelected = { token in
            self.collectionTagTextFieldModel.tokens.removeAll(where: { $0 == token })
            if self.collectionTagTextFieldModel.tokens.isEmpty {
                self.collectionTagTextFieldModel.prompt = initialPrompt
                self.collectionTagTextFieldModel.promptColor = nil
            }
        }
        
        // add tag action
        collectionTagTextFieldModel.onReturnKey = {
            let newToken = self.collectionTagTextFieldModel.text.trimmed().replacingOccurrences(of: ",", with: "")
            
            // check duplicate
            if self.collectionTagTextFieldModel.tokens.contains(newToken) {
                self.collectionTagTextFieldModel.prompt = "Duplicate tag"
                self.collectionTagTextFieldModel.promptColor = .red
                return
            }
            
            // check limit
            if self.collectionTagTextFieldModel.tokens.count == maxTags {
                self.collectionTagTextFieldModel.prompt = "Cannot have more than \(maxTags) tags 🥺"
                self.collectionTagTextFieldModel.promptColor = .orange
                return
            }
            
            // add tag
            self.collectionTagTextFieldModel.tokens.append(newToken)
            self.collectionTagTextFieldModel.text = ""
            self.collectionTagTextFieldModel.prompt = ""
        }
        
        // commit tags action
        collectionTagTextFieldModel.onCommit = {
            self.viewModel.publishTags = self.collectionTagTextFieldModel.tokens
            self.sheet = nil
        }
    }
}


extension PublishCollectionForm {
    
    enum Sheet: Identifiable {
        var id: Self { self }
        case publishCollection
        case publishDescription
        case publishTags
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .publishDescription:
            return ModalTextView(viewModel: $collectionDescriptionTextViewModel)
                .eraseToAnyView()
        
        case .publishTags:
            return ModalTextField(viewModel: $collectionTagTextFieldModel)
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





