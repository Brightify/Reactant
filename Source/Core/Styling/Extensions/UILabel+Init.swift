//
//  UILabel+Init.swift
//  Lipstick
//
//  Created by Tadeas Kriz on 31/03/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if os(iOS)
import UIKit

extension UILabel {
    
    public convenience init(text: String) {
        self.init()
        
        self.text = text
    }
}
#endif
