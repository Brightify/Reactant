//
//  CGPoint+Init.swift
//  Lipstick
//
//  Created by Filip Dolnik on 16.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    
    public init(_ both: CGFloat) {
        self.init(x: both, y: both)
    }
    
    public init(x: CGFloat) {
        self.x = x
        self.y = 0
    }
    
    public init(y: CGFloat) {
        self.x = 0
        self.y = y
    }
}
