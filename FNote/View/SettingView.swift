//
//  SettingView.swift
//  FNote
//
//  Created by Dara Beng on 9/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct SettingView: View {
    
    @EnvironmentObject var noteCardCollectionDataSource: NoteCardCollectionDataSource
    
    @EnvironmentObject var tagDataSource: TagDataSource
    
    
    var body: some View {
        NavigationView {
            List {
                Button("Create New Collection & Set Current", action: createNewCollectionAndSetCurrent)
                Button("Deselect Current Collection", action: deselectCurrentCollection)
                Button("Creat New Tag", action: createNewTag)
            }
            .navigationBarTitle("Settings")
        }
    }
}


extension SettingView {
    
    func createNewCollectionAndSetCurrent() {
        noteCardCollectionDataSource.prepareNewObject()
        let collection = noteCardCollectionDataSource.newObject!
        print(collection.uuid)
        collection.name = "Collection \(Int.random(in: 1...9999))"
        let result = noteCardCollectionDataSource.saveNewObject()
        AppCache.currentCollectionUUID = collection.uuid
        print(result)
        noteCardCollectionDataSource.discardNewObject()
    }
    
    func deselectCurrentCollection() {
        AppCache.currentCollectionUUID = nil
    }
    
    func createNewTag() {
        tagDataSource.prepareNewObject()
        let tag = tagDataSource.newObject!
        tag.name = "Tag \(tagDataSource.fetchedResult.fetchedObjects!.count + 1)"
        let result = tagDataSource.saveNewObject()
        print("created Tag \(result)")
        tagDataSource.discardNewObject()
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
