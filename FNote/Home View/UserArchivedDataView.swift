//
//  UserArchivedDataView.swift
//  FNote
//
//  Created by Dara Beng on 5/18/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct UserArchivedDataView: View {
    
    var collectionViewModel: NoteCardCollectionCollectionViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("description")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                    .padding()
                Divider()
                if collectionViewModel.collections.isEmpty {
                    VStack(spacing: 0) {
                        Spacer()
                        Image(systemName: "archivebox.fill")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.secondary)
                        Text("No Archives")
                            .foregroundColor(.secondary)
                            .padding(24)
                        Spacer()
                    }
                } else {
                    CollectionViewWrapper(viewModel: collectionViewModel)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .navigationBarTitle("Archives", displayMode: .inline)
        }
    }
}


struct UserArchivedDataView_Previews: PreviewProvider {
    static let model = NoteCardCollectionCollectionViewModel()
    static var previews: some View {
        UserArchivedDataView(collectionViewModel: model)
    }
}
