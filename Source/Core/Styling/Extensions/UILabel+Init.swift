//
//  UILabel+Init.swift
//  Reactant
//
//  Created by Tadeas Kriz on 31/03/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UILabel {
    
    public convenience init(text: String) {
        self.init()
        
        self.text = text
    }
}
#endif
