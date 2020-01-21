//
//  HomeNoteCardView.swift
//  FNote
//
//  Created by Dara Beng on 1/20/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI
import CoreData


struct HomeNoteCardView: View {
    
    var viewModel: NoteCardCollectionViewModel
    
    var collection: NoteCardCollection
    
    var updateContext: NSManagedObjectContext
    
    @State private var sheet: Sheet?
    @State private var noteCardFormModel: NoteCardFormModel?
    
    @FetchRequest(fetchRequest: NoteCardCollection.requestAllCollections())
    private var allCollections
    
    @FetchRequest(fetchRequest: Tag.requestAllTags())
    private var allTags
    
    
    var body: some View {
        NavigationView {
            NoteCardCollectionViewWrapper(viewModel: viewModel)
                .navigationBarTitle(Text(collection.name), displayMode: .large)
                .navigationBarItems(trailing: createNoteCardNavItem)
                .edgesIgnoringSafeArea(.all)
                .onAppear(perform: setupViewModelActions)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $sheet, content: presentationSheet)
    }
}


// MARK: - Sheet

extension HomeNoteCardView {
    
    enum Sheet: Identifiable {
        var id: Self { self }
        case noteCardForm
    }
    
    func presentationSheet(for sheet: Sheet) -> some View {
        switch sheet {
        case .noteCardForm:
            return NoteCardForm(viewModel: noteCardFormModel!)
        }
    }
}



// MARK: - Create Note Card

extension HomeNoteCardView {
    
    var createNoteCardNavItem: some View {
        Button(action: beginCreateNoteCard) {
            Image(systemName: "plus")
                .imageScale(.large)
        }
    }
    
    func beginCreateNoteCard() {
        noteCardFormModel = .init(context: updateContext, collection: collection)
        
        noteCardFormModel?.selectableCollections = Array(allCollections)
        noteCardFormModel?.selectableRelationships = Array(collection.noteCards)
        noteCardFormModel?.selectableTags = Array(allTags)
        
        noteCardFormModel?.onCancel = cancelCreateNoteCard
        noteCardFormModel?.onCommit = commitCreateNoteCard
        
        noteCardFormModel?.commitTitle = "Create"
        noteCardFormModel?.navigationTitle = "Create Note Card"
        
        sheet = .noteCardForm
    }
    
    func cancelCreateNoteCard() {
        noteCardFormModel = nil
        sheet = nil
    }
    
    func commitCreateNoteCard() {
        sheet = nil
    }
}


// MARK: - Edit Note Card

extension HomeNoteCardView {
    
    func setupViewModelActions() {
        viewModel.onNoteCardSelected = beginEditNoteCard
    }
    
    func beginEditNoteCard(_ noteCard: NoteCard) {
        guard let collection = noteCard.collection else { return }
        noteCardFormModel = .init(context: updateContext, collection: collection)
        
        noteCardFormModel?.selectableCollections = Array(allCollections)
        noteCardFormModel?.selectableRelationships = Array(collection.noteCards)
        noteCardFormModel?.selectableTags = Array(allTags)
        
        noteCardFormModel?.onCancel = cancelEditNoteCard
        noteCardFormModel?.onCommit = { self.commitEditNoteCard(noteCard) }
        
        noteCardFormModel?.update(with: noteCard)
        noteCardFormModel?.commitTitle = "Update"
        noteCardFormModel?.navigationTitle = "Note Card Detail"
        noteCardFormModel?.nativePlaceholder = noteCard.native
        noteCardFormModel?.translationPlaceholder = noteCard.translation
        
        sheet = .noteCardForm
    }
    
    func cancelEditNoteCard() {
        noteCardFormModel = nil
        sheet = nil
    }
    
    func commitEditNoteCard(_ noteCard: NoteCard) {
        sheet = nil
    }
}


struct HomeNoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        HomeNoteCardView(viewModel: .init(), collection: .sample, updateContext: .sample)
    }
}
