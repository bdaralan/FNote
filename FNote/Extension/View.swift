//
//  View.swift
//  FNote
//
//  Created by Brittney Witts on 9/18/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

extension View {
    
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
    
    func frameInfinity(alignment: Alignment) -> some View {
        frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: alignment)
    }
}
