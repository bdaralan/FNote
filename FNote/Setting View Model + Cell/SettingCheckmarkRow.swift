//
//  SettingCheckmarkRow.swift
//  FNote
//
//  Created by Dara Beng on 1/31/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct SettingCheckmarkRow: View {
    
    var label: String
    var checked: Bool
    
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            
            Spacer()
            
            if checked {
                Image(systemName: "checkmark")
                    .foregroundColor(.primary)
            }
        }
            .modifier(SettingRowModifier())
    }
}


struct SettingIconRow_Previews: PreviewProvider {
    static var previews: some View {
        SettingCheckmarkRow(label: "System", checked: true)
    }
}
