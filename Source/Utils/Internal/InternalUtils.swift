//
//  InternalUtils.swift
//  Reactant
//
//  Created by Filip Dolnik on 26.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

internal func degreesToRadians(_ value: Double) -> Double {
    return value * M_PI / 180.0
}

internal func radiansToDegrees(_ value: Double) -> Double {
    return value * 180.0 / M_PI
}

extension Double {
    
    internal func equal(to value: Double, precision: Double = DBL_EPSILON) -> Bool {
        return abs(self - value) <= precision
    }
}
