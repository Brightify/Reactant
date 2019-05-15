//
//  UIOffset+Init.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UIOffset {
    
    public init(_ all: CGFloat) {
        self.init(horizontal: all, vertical: all)
    }
    
    public init(horizontal: CGFloat) {
        self.init(horizontal: horizontal, vertical: 0)
    }
    
    public init(vertical: CGFloat) {
        self.init(horizontal: 0, vertical: vertical)
    }
}
#endif
