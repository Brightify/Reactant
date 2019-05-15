//
//  CGRect+Init.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreGraphics

extension CGRect {

    public init(x: CGFloat, width: CGFloat = 0, height: CGFloat = 0) {
        self.init(x: x, y: 0, width: width, height: height)
    }

    public init(y: CGFloat, width: CGFloat = 0, height: CGFloat = 0) {
        self.init(x: 0, y: y, width: width, height: height)
    }

    public init(x: CGFloat, y: CGFloat) {
        self.init(x: x, y: y, width: 0, height: 0)
    }

    public init(x: CGFloat, y: CGFloat, width: CGFloat) {
        self.init(x: x, y: y, width: width, height: 0)
    }

    public init(x: CGFloat, y: CGFloat, height: CGFloat) {
        self.init(x: x, y: y, width: 0, height: height)
    }
    
    public init(width: CGFloat) {
        self.init(x: 0, y: 0, width: width, height: 0)
    }

    public init(height: CGFloat) {
        self.init(x: 0, y: 0, width: 0, height: height)
    }

    public init(width: CGFloat, height: CGFloat) {
        self.init(x: 0, y: 0, width: width, height: height)
    }

    public init(x: CGFloat = 0, y: CGFloat = 0, size: CGSize) {
        self.init(origin: CGPoint(x: x, y: y), size: size)
    }
    
    public init(origin: CGPoint, width: CGFloat = 0, height: CGFloat = 0) {
        self.init(origin: origin, size: CGSize(width: width, height: height))
    }
}
