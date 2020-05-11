//
//  PublicCollectionDetailViewHeader.swift
//  FNote
//
//  Created by Dara Beng on 5/11/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct PublicCollectionDetailViewHeader: View {
    
    var collection: PublicCollection
    
    @State private var showDescription = false
    
    var creationDate: String {
        guard let date = collection.record?.creationDate else { return "???" }
        return PublicCollectionCell.dateFormatter.string(from: date)
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Collection Name
            Text(collection.name).bold()
            
            // Language & Card Count
            HStack {
                Text("\(collection.primaryLanguage.localized) - \(collection.secondaryLanguage.localized)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(String(quantity: collection.cardsCount, singular: "CARD", plural: "CARDS"))
            }
            .font(.footnote)
            
            // Author & Date
            HStack {
                HStack(spacing: 0) {
                    Text("by ").foregroundColor(.secondary)
                    Text(collection.authorName)
                }
                Spacer()
                Text(creationDate)
            }
            .font(.footnote)
            
            HStack {
                // Collection Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(collection.tags, id: \.self) { tag in
                            Text(tag)
                                .frame(minWidth: 30)
                                .font(.footnote)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 8)
                                .foregroundColor(.primary)
                                .background(Color.noteCardBackground)
                                .cornerRadius(20)
                        }
                    }
                }
                
                Divider().frame(maxHeight: 16)
                
                // Description Button
                Button(action: { self.$showDescription.animation(.spring()).wrappedValue.toggle() }) {
                    Text("description")
                        .font(.footnote)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .foregroundColor(.appAccent)
                        .background(Color.noteCardBackground)
                        .cornerRadius(20)
                }
            }
            .padding(.top, 4)
            
            // Description Text
            if showDescription {
                Text(collection.description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.callout)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 4)
            }
        }
    }
}


struct PublicCollectionDetailViewHeader_Previews: PreviewProvider {
    static let collection = PublicCollection(
        collectionID: "collectionID", authorID: "authorID",
        authorName: "author", name: "Collection Name", description: "description",
        primaryLanguageCode: "kor", secondaryLanguageCode: "en",
        //primaryLanguageCode: "ase", secondaryLanguageCode: "tzm",
        tags: ["tag01", "tag02", "tag03", "tag04"], cardsCount: 9
    )
    static var previews: some View {
        VStack {
            PublicCollectionDetailViewHeader(collection: collection)
                .padding(.horizontal)
            Divider()
            Spacer()
        }
    }
}
