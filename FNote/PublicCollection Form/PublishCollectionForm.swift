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
    
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    // MARK: Author
                    ScrollViewSection(header: publishAuthorHeader, footer: publishAuthorFooter) {
                        Text(viewModel.uiAuthorName)
                            .foregroundColor(viewModel.authorName.isEmpty ? .secondary : .primary)
                            .modifier(InsetRowStyle())
                            .onTapGesture(perform: handleAuthorTapped)
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
                            Text(viewModel.uiCollectionPublishName)
                                .foregroundColor(viewModel.publishCollectionName.isEmpty ? .secondary : .primary)
                                .modifier(InsetRowStyle())
                                .onTapGesture(perform: handleCollectionNameTapped)
                            
                            Text(viewModel.uiCollectionDescription)
                                .padding(.top)
                                .foregroundColor(viewModel.publishDescription.isEmpty ? .secondary : .primary)
                                .modifier(InsetRowStyle(height: 110, alignment: .topLeading))
                                .onTapGesture(perform: handleDescriptionTapped)
                            
                            Text(viewModel.uiCollectionTags)
                                .foregroundColor(viewModel.publishTags.isEmpty ? .secondary : .primary)
                                .modifier(InsetRowStyle())
                                .onTapGesture(perform: handleTagTapped)
                            
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
    }
}


extension PublishCollectionForm {
    
    func handleAuthorTapped() {
        viewModel.authorName = "bdlan"
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
    
    func handleCollectionNameTapped() {
        viewModel.publishCollectionName = "Publish Title"
    }
    
    func handleDescriptionTapped() {
        let name = viewModel.publishCollection?.name ?? "nil collection"
        viewModel.publishDescription = "Short description of the \(name)"
    }
    
    func handleTagTapped() {
        viewModel.publishTags = ["Travel", "Greeting", "Food", "Street"]
    }
    
    func handleLanguagesTapped() {
        viewModel.publishPrimaryLanguage = "KRN"
        viewModel.publishSecondaryLanguage = "ENG"
    }
    
    func handlePublishTapped() {
        viewModel.onCommit?()
        
        guard viewModel.hasValidInputs, let collection = viewModel.publishCollection else { return }
        let publicCollection = PublicCollection(
            collectionID: collection.uuid,
            authorID: viewModel.authorName,
            name: collection.name,
            description: viewModel.publishDescription,
            primaryLanguage: "KRN",
            secondaryLanguage: "ENG",
            tags: viewModel.publishTags,
            cardsCount: collection.noteCards.count
        )
        
        let cards = collection.noteCards.map { noteCard in
            PublicNoteCard(
                collectionID: publicCollection.collectionID,
                cardID: noteCard.uuid,
                native: noteCard.native,
                translation: noteCard.translation,
                favorited: noteCard.isFavorite,
                formality: Int(noteCard.formality.rawValue),
                note: noteCard.note,
                tags: noteCard.tags.map({ $0.name }),
                relationships: []
            )
        }
        
        PublicRecordManager.shared.upload(collection: publicCollection, with: cards) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.viewModel.commitTitle = "PUBLISHED"
                case .failure(let error):
                    print(error)
                    self.viewModel.commitTitle = "FAILED"
                }
            }
        }
    }
}


struct PublishCollectionForm_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PublishCollectionForm(viewModel: .init()).colorScheme(.light)
            PublishCollectionForm(viewModel: .init()).colorScheme(.dark)
        }
    }
}


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
    
    var onCommit: (() -> Void)?
    
    var onCancel: (() -> Void)?
}


// MARK: Display Property

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
        publishDescription.isEmpty ? "a breif description of the collection..." : publishDescription
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


