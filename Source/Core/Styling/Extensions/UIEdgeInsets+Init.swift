//
//  UIEdgeInsets+Init.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation
import CoreGraphics

extension Platform.EdgeInsets {
    
    public init(left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: 0, left: left, bottom: bottom, right: right)
    }
    
    public init(top: CGFloat, bottom: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: top, left: 0, bottom: bottom, right: right)
    }
    
    public init(top: CGFloat, left: CGFloat, right: CGFloat = 0) {
        self.init(top: top, left: left, bottom: 0, right: right)
    }
    
    public init(top: CGFloat, left: CGFloat, bottom: CGFloat) {
        self.init(top: top, left: left, bottom: bottom, right: 0)
    }

    public init(_ all: CGFloat) {
        self.init(horizontal: all, vertical: all)
    }
    
    public init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
    
    public init(horizontal: CGFloat, top: CGFloat = 0, bottom: CGFloat = 0) {
        self.init(top: top, left: horizontal, bottom: bottom, right: horizontal)
    }
    
    public init(vertical: CGFloat, left: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: vertical, left: left, bottom: vertical, right: right)
    }
}
