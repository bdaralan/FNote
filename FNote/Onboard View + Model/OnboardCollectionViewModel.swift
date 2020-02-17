//
//  OnboardCollectionViewModel.swift
//  FNote
//
//  Created by Dara Beng on 2/13/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import UIKit


// MARK: - Onboard View Model

class OnboardCollectionViewModel: ObservableObject {
    
    let pages = OnboardPage.load()
    
    @Published var currentPage = 0
    
    @Published var hasLastPageShown = false
}
