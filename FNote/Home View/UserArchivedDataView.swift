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
    
    var onDone: (() -> Void)?
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("These are previous version data. If they have not been automatically imported, you can import them manually.")
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                    Text("Tap to view or Long Press to see import option")
                        .font(.callout)
                        .foregroundColor(.primary)
                        .padding()
                    Divider()
                    CollectionViewWrapper(viewModel: collectionViewModel)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .navigationBarTitle("Archived Collections", displayMode: .inline)
            .navigationBarItems(trailing: doneNavItem)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    var doneNavItem: some View {
        Button(action: onDone ?? {}) {
            Text("Done").bold()
        }
    }
}


struct UserArchivedDataView_Previews: PreviewProvider {
    static let model = NoteCardCollectionCollectionViewModel()
    static var previews: some View {
        UserArchivedDataView(collectionViewModel: model)
    }
}
