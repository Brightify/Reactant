//
//  UIFont+Init.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UIFont {
    
    public convenience init(_ name: String, _ size: CGFloat) {
        self.init(descriptor: UIFontDescriptor(name: name, size: size), size: 0)
    }
}
#endif
