//
//  CGAffineTransform+Shortcut.swift
//  Reactant
//
//  Created by Filip Dolnik on 16.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreGraphics

public func + (lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform {
    return lhs.concatenating(rhs)
}

public func rotate(degrees: CGFloat) -> CGAffineTransform {
    return rotate(degrees / 180 * .pi)
}

public func rotate(_ radians: CGFloat = 0) -> CGAffineTransform {
    return CGAffineTransform(rotationAngle: radians)
}

public func translate(x: CGFloat = 0, y: CGFloat = 0) -> CGAffineTransform {
    return CGAffineTransform(translationX: x, y: y)
}

public func scale(x: CGFloat = 1, y: CGFloat = 1) -> CGAffineTransform {
    return CGAffineTransform(scaleX: x, y: y)
}
