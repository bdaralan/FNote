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
    
    func hidden(_ condition: Bool) -> some View {
        condition ? AnyView(EmptyView()) : AnyView(self)
    }
}
