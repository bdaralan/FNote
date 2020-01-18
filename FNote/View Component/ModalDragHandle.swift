//
//  ModalDragHandle.swift
//  FNote
//
//  Created by Dara Beng on 10/21/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import SwiftUI

struct ModalDragHandle: View {
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var hideOnLandscape = false
    
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .frame(width: 50, height: 4, alignment: .center)
            .foregroundColor(.primary)
            .opacity((hideOnLandscape && verticalSizeClass == .compact) ? 0 : 1)
    }
}

struct ModalDragHandle_Previews: PreviewProvider {
    static var previews: some View {
        ModalDragHandle()
    }
}
