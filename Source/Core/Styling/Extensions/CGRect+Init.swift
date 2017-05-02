//
//  CGRect+Init.swift
//  Lipstick
//
//  Created by Filip Dolnik on 16.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

extension CGRect {
    
    public init(x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0) {
        self.init(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
    }
    
    public init(x: CGFloat = 0, y: CGFloat = 0, size: CGSize) {
        self.init(origin: CGPoint(x: x, y: y), size: size)
    }
    
    public init(origin: CGPoint, width: CGFloat = 0, height: CGFloat = 0) {
        self.init(origin: origin, size: CGSize(width: width, height: height))
    }
}
