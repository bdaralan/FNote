//
//  CreateUpdateSheetState.swift
//  FNote
//
//  Created by Dara Beng on 9/29/19.
//  Copyright © 2019 Dara Beng. All rights reserved.
//

import Foundation


enum CreateUpdateSheetState: Int, Identifiable {
    var id: Int { rawValue }
    case create
    case update
}
