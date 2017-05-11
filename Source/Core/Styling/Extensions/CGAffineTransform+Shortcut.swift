//
//  CGAffineTransform+Shortcut.swift
//  Lipstick
//
//  Created by Filip Dolnik on 16.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreGraphics

public func + (lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform {
    return lhs.concatenating(rhs)
}

public func rotate(_ degrees: CGFloat = 0) -> CGAffineTransform {
    return CGAffineTransform(rotationAngle: degrees)
}

public func translate(x: CGFloat = 0, y: CGFloat = 0) -> CGAffineTransform {
    return CGAffineTransform(translationX: x, y: y)
}

public func scale(x: CGFloat = 1, y: CGFloat = 1) -> CGAffineTransform {
    return CGAffineTransform(scaleX: x, y: y)
}
