//
//  SettingTextRow.swift
//  FNote
//
//  Created by Dara Beng on 1/31/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import SwiftUI


struct SettingTextRow: View {
    
    var label: String
    var detail: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(detail)
                .foregroundColor(.secondary)
        }
        .modifier(SettingRowModifier())
    }
}


struct SettingTextRow_Previews: PreviewProvider {
    static var previews: some View {
        SettingTextRow(label: "Label", detail: "Detail")
    }
}
