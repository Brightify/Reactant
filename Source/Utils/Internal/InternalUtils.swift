//
//  InternalUtils.swift
//  Reactant
//
//  Created by Filip Dolnik on 26.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

internal func degreesToRadians(_ value: Double) -> Double {
    return value * Double.pi / 180.0
}

internal func radiansToDegrees(_ value: Double) -> Double {
    return value * 180.0 / Double.pi
}

extension Double {
    
    internal func equal(to value: Double, precision: Double = Double.ulpOfOne) -> Bool {
        return abs(self - value) <= precision
    }
}

#if DEBUG
    func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
        #if _runtime(_ObjC)
            NSException(name: .internalInconsistencyException, reason: message(), userInfo: nil).raise()
        #endif

        Swift.fatalError(message(), file: file, line: line)
    }

    public func preconditionFailure(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
        #if _runtime(_ObjC)
            NSException(name: .internalInconsistencyException, reason: message(), userInfo: nil).raise()
        #endif

        Swift.fatalError(message(), file: file, line: line)
    }
#endif
