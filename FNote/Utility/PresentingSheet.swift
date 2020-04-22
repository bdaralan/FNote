//
//  PresentingSheet.swift
//  FNote
//
//  Created by Dara Beng on 4/3/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation


protocol PresentationSheetItem: Identifiable {}

extension PresentationSheetItem {
    var id: Self { self }
}
