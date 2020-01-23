//
//  HomeNoteCardCollectionView.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct HomeNoteCardCollectionView: View {
    
    @EnvironmentObject var appState: AppState
    
    var onCurrentCollectionChanged: ((NoteCardCollection) -> Void)?
    
    @State private var sheet: Sheet?
    
    @State private var modalTextFieldModel = ModalTextFieldModel()
    
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 16) {
                    ForEach(appState.collections) { collection in
                        NoteCardCollectionRow(
                            collection: collection,
                            showCheckmark: collection === self.appState.currentCollection
                        )
                            .onTapGesture(perform: { self.handleNoteCardCollectionSelected(collection) })
                            .contextMenu(menuItems: { self.contextMenuItems(for: collection) })
                    }
                }
                .padding()
            }
            .navigationBarTitle("Collections", displayMode: .large)
            .navigationBarItems(trailing: createNoteCardCollectionNavItem)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet, content: presentationSheet)
    }
}


// MARK: - Sheet

extension HomeNoteCardCollectionView {
    
    enum Sheet: Identifiable {
        var id: Self { self }
        case modalTextField
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .modalTextField:
            return ModalTextField(viewModel: $modalTextFieldModel)
        }
    }
}


// MARK: Context Menu

extension HomeNoteCardCollectionView {
    
    func contextMenuItems(for collection: NoteCardCollection) -> some View {
        Group {
            Button(action: { self.beginRenameNoteCardCollection(collection) }) {
                Text("Rename")
                Image(systemName: "square.and.pencil")
            }
            Button(action: {}) {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
}


// MARK: Create Collection

extension HomeNoteCardCollectionView {
    
    var createNoteCardCollectionNavItem: some View {
        NavigationBarButton(imageName: "plus", action: beginCreateNoteCardCollection)
    }
    
    func beginCreateNoteCardCollection() {
        modalTextFieldModel = .init()
        
        modalTextFieldModel.title = "New Collection"
        modalTextFieldModel.placeholder = "Collection Name"
        modalTextFieldModel.isFirstResponder = true
        
        modalTextFieldModel.onCommit = commitCreateNoteCardCollection
        
        sheet = .modalTextField
    }
    
    func commitCreateNoteCardCollection() {
        sheet = nil
    }
}


// MARK: Rename Collection

extension HomeNoteCardCollectionView {
    
    func beginRenameNoteCardCollection(_ collection: NoteCardCollection) {
        modalTextFieldModel = .init()
        
        modalTextFieldModel.title = "Rename"
        modalTextFieldModel.text = collection.name
        modalTextFieldModel.placeholder = collection.name
        modalTextFieldModel.isFirstResponder = true
        
        modalTextFieldModel.onCommit = {
            self.commitRenameNoteCardCollection(collection)
        }
        
        sheet = .modalTextField
    }
    
    func commitRenameNoteCardCollection(_ collection: NoteCardCollection) {
        sheet = nil
    }
}


// MARK: - Action

extension HomeNoteCardCollectionView {
    
    func handleNoteCardCollectionSelected(_ collection: NoteCardCollection) {
        appState.setCurrentCollection(collection)
    }
}


struct HomeNoteCardCollectionView_Previews: PreviewProvider {
    static let samples = [NoteCardCollection.sample, .sample, .sample]
    static var previews: some View {
        HomeNoteCardCollectionView()
    }
}
