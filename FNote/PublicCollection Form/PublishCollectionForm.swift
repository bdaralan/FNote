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
                    Group {
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
        viewModel.publishPrimaryLanguage = "KOR"
        viewModel.publishSecondaryLanguage = "ENG"
    }
    
    func handlePublishTapped() {
        viewModel.onCommit?()
    }
}


struct PublishCollectionForm_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Color.red.edgesIgnoringSafeArea(.all).sheet(isPresented: .constant(true)) {
                PublishCollectionForm(viewModel: .init()).colorScheme(.light)
            }
            
            Color.red.edgesIgnoringSafeArea(.all).sheet(isPresented: .constant(true)) {
                PublishCollectionForm(viewModel: .init()).colorScheme(.dark)
            }
        }
    }
}





