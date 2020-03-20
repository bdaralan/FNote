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
    
    @State private var isAuthorTextFieldActive = false
    @State private var isCollectionNameTextFieldActive = false
    @State private var isCollectionDescriptionTextFieldActive = false
    
    @State private var collectionDescriptionTextViewModel = ModalTextViewModel()
    @State private var collectionTagTextFieldModel = ModalTextFieldModel()
    
    
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
                                configure: configureTextField
                            )
                            .modifier(InsetRowStyle())
                        }
                        
                        // MARK: Publish Collection
                        ScrollViewSection(header: publishCollectionHeader) {
                            HStack {
                                Text(viewModel.uiCollectionName)
                                    .font(Font.body.bold())
                                    .foregroundColor(viewModel.publishCollection == nil ? .secondary : .primary)
                                Spacer()
                                Text(viewModel.uiCollectionCardsCount)
                                    .foregroundColor(.secondary)
                                    .opacity(viewModel.publishCollection == nil ? 0 : 1)
                            }
                            .modifier(InsetRowStyle())
                            .onTapGesture(perform: handleCollectionTapped)
                        }
                        
                        // MARK: - Publish Details
                        ScrollViewSection(header: publishCollectionDetailHeader) {
                            VStack(spacing: 5) {
                                TextFieldWrapper(
                                    isActive: $isCollectionNameTextFieldActive,
                                    text: $viewModel.publishCollectionName,
                                    placeholder: "collection name",
                                    configure: configureTextField
                                )
                                    .modifier(InsetRowStyle())
                                
                                Text(viewModel.uiCollectionDescription)
                                    .padding(.top)
                                    .foregroundColor(viewModel.publishDescription.isEmpty ? .secondary : .primary)
                                    .modifier(InsetRowStyle(height: 110, alignment: .topLeading))
                                    .onTapGesture(perform: beginEditingCollectionDescription)
                                
                                Text(viewModel.uiCollectionTags)
                                    .foregroundColor(viewModel.publishTags.isEmpty ? .secondary : .primary)
                                    .modifier(InsetRowStyle())
                                    .onTapGesture(perform: beginEditingCollectionTags)
                                
                                Text(viewModel.uiLanguages)
                                    .foregroundColor(viewModel.isLanguagesValid ? .primary : .secondary)
                                    .modifier(InsetRowStyle())
                                    .onTapGesture(perform: handleLanguagesTapped)
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
                        Button(action: handlePublishTapped) {
                            Text(viewModel.commitTitle)
                                .font(Font.body.weight(.black))
                                .frame(maxWidth: .infinity)
                                .foregroundColor(colorScheme == .light ? .black : .white)
                                .modifier(InsetRowStyle(height: 60, borderColor: .primary, borderWidth: 2))
                        }
                        .disabled(!viewModel.hasValidInputs)
                        .opacity(viewModel.hasValidInputs ? 1 : 0.5)
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
    }
}


extension PublishCollectionForm {
    
    func configureTextField(_ textField: UITextField) {
        textField.font = .preferredFont(forTextStyle: .body)
    }
    
    func handleCollectionTapped() {
        let collection = NoteCardCollection(context: .sample)
        collection.name = "Publish Collection \(Int.random(in: 1...100))"
        for i in 4...9 {
            let card = NoteCard(context: .sample)
            let number = i + 1
            card.native = "native \(number)"
            card.translation = "translation \(number)"
            card.note = "note \(number)"
            card.formality = NoteCard.Formality.allCases.randomElement()!
            card.collection = collection
        }
        viewModel.publishCollection = collection
    }
    
    func handleLanguagesTapped() {
        viewModel.publishPrimaryLanguage = "KOR"
        viewModel.publishSecondaryLanguage = "ENG"
    }
    
    func handlePublishTapped() {
        viewModel.onCommit?()
    }
    
    func beginEditingCollectionDescription() {
        collectionDescriptionTextViewModel.title = "Brief Description"
        collectionDescriptionTextViewModel.text = viewModel.publishDescription
        collectionDescriptionTextViewModel.disableEditing = false
        collectionDescriptionTextViewModel.renderMarkdown = false
        collectionDescriptionTextViewModel.isFirstResponder = true
        collectionDescriptionTextViewModel.onCommit = {
            self.viewModel.publishDescription = self.collectionDescriptionTextViewModel.text
            self.collectionDescriptionTextViewModel.isFirstResponder = false
            self.sheet = nil
        }
        sheet = .publishDescription
    }
    
    func beginEditingCollectionTags() {
        collectionTagTextFieldModel = .init()
        collectionTagTextFieldModel.title = "Tags"
        collectionTagTextFieldModel.prompt = "Can add up to \(publishTagsLimit) tags"
        collectionTagTextFieldModel.tokens = viewModel.publishTags
        collectionTagTextFieldModel.isFirstResponder = true
        collectionTagTextFieldModel.returnKeyType = .default
        sheet = .publishTags
        
        
        
        // remove tag action
        collectionTagTextFieldModel.onTokenSelected = { token in
            self.collectionTagTextFieldModel.tokens.removeAll(where: { $0 == token })
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
            let limit = self.publishTagsLimit
            if self.collectionTagTextFieldModel.tokens.count == limit {
                self.collectionTagTextFieldModel.prompt = "Cannot have more than \(limit) tags 🥺"
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





