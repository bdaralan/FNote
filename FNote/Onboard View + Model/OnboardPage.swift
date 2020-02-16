//
//  OnboardPage.swift
//  FNote
//
//  Created by Dara Beng on 2/14/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation


struct OnboardPage: Decodable, Hashable {
    let title: String
    let description: String
    let imageName: String
}


extension OnboardPage {
    
    static func load() -> [OnboardPage] {
        Bundle.main.loadJSON(resource: "onboard-pages", result: [OnboardPage].self)
    }
}
