//
//  UserArchivedDataView.swift
//  FNote
//
//  Created by Dara Beng on 5/15/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import BDUIKnit


class UserArchivedDataViewModel: ObservableObject {
    
    @Published var title = "Archived Data"
    
    @Published var message = ""
    
    var onDismiss: (() -> Void)?
    
    /// The boolean indicates whether the import is successful.
    var onImport: (((Bool) -> Void) -> Void)?
    
    let collectionViewModel = NoteCardCollectionCollectionViewModel()
}


struct UserArchivedDataView: View {
    
    @ObservedObject var viewModel: UserArchivedDataViewModel
    
    @State private var trayViewModel = BDButtonTrayViewModel()
    
    private let importItemImage = BDButtonTrayItemImage.system(SFSymbol.addCollection)
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.message.isEmpty == false {
                    Text(viewModel.message)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding()
                    Divider()
                }
                
                ZStack {
                    CollectionViewWrapper(viewModel: viewModel.collectionViewModel)
                        .edgesIgnoringSafeArea(.all)
                    Color.clear
                        .overlay(BDButtonTrayView(viewModel: trayViewModel).padding(16), alignment: .bottomTrailing)
                }
                    
            }
            .navigationBarTitle(Text(viewModel.title), displayMode: .inline)
            .onAppear(perform: setupOnAppear)
        }
    }
}


extension UserArchivedDataView {
    
    func setupOnAppear() {
        trayViewModel.setDefaultColors()
        trayViewModel.shouldDisableMainItemWhenExpanded = false
        trayViewModel.expanded = true
        trayViewModel.locked = true
        
        trayViewModel.mainItem = .init(title: "", image: .system(SFSymbol.dismiss)) { item in
            self.viewModel.onDismiss?()
        }
        
        let importData = BDButtonTrayItem(title: "Import", image: importItemImage, disabled: viewModel.onImport == nil) { item in
            self.beginImport(item: item)
        }
        
        trayViewModel.items = [importData]
        
        viewModel.collectionViewModel.contentInsets.bottom = 140 + CGFloat(trayViewModel.items.count * 70)
    }
    
    func beginImport(item: BDButtonTrayItem) {
        item.disabled = true
        item.inactiveColor = .appAccent
        item.image = .system(SFSymbol.loading)
        item.animation = .rotation()
        item.title = "Importing..."
        
        self.viewModel.onImport?() { completed in
            // the import can happens in an instant so add delay to create a loading impression.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                item.title = completed ? "Imported" : "Failed! try again."
                item.disabled = completed
                item.inactiveColor = .green
                item.activeColor = .red
                item.animation = nil
                item.image = self.importItemImage
            }
        }
    }
}


struct UserArchivedDataView_Previews: PreviewProvider {
    static var previews: some View {
        UserArchivedDataView(viewModel: .init())
    }
}
