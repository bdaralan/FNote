//
//  Down+Extension.swift
//  FNote
//
//  Created by Dara Beng on 4/21/20.
//  Copyright © 2020 Dara Beng. All rights reserved.
//

import Foundation
import Down


extension Down {
    
    func markdown(options: DownOptions, colors: ColorCollection) -> NSAttributedString? {
        var config = DownStylerConfiguration()
        config.colors = colors
        let styler = DownStyler(configuration: config)
        return try? toAttributedString(options, styler: styler)
    }
}
