//
//  Image.swift
//  FNote
//
//  Created by Dara Beng on 10/9/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI


extension Image {
        
    static let noteCardRelationship = Image(systemName: "rectangle.on.rectangle")
    
    static let noteCardTag = Image(systemName: "tag")
    
    static let noteCardNote = Image(systemName: "doc.plaintext")
    
    static func noteCardFavorite(_ enable: Bool) -> Image {
        Image(systemName: enable ? "star.fill" : "star")
    }
}


extension UIImage {
    
    static func preload(name: String) {
        let _ = UIImage(named: name)
    }
}
