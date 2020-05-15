//
//  NoteCardDetailPresenterModel.swift
//  FNote
//
//  Created by Dara Beng on 5/9/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation


class NoteCardDetailPresenterModel: ObservableObject {
    
    @Published var sheet: NoteCardDetailPresenter.Sheet?
    
    var appState: AppState
    
    var renderMarkdown = true
    
    var renderSoftBreak = true
    
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    
    func setFavorite(_ favorited: Bool, for noteCard: NoteCard) {
        var modifier = ObjectModifier<NoteCard>(.update(noteCard))
        modifier.favorited = favorited
        modifier.save()
    }
}
