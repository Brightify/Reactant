//
//  AssociatedObject.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public func associatedObject<T>(_ base: Any, key: UnsafePointer<UInt8>, defaultValue: @autoclosure () -> T) -> T {
    if let associated = objc_getAssociatedObject(base, key) as? T {
        return associated
    } else {
        let value = defaultValue()
        associateObject(base, key: key, value: value)
        return value
    }
}

public func associatedObject<T>(_ base: Any, key: UnsafePointer<UInt8>, initializer: () -> T) -> T {
    if let associated = objc_getAssociatedObject(base, key) as? T {
        return associated
    } else {
        let defaultValue = initializer()
        associateObject(base, key: key, value: defaultValue)
        return defaultValue
    }
}

public func associateObject<T>(_ base: Any, key: UnsafePointer<UInt8>, value: T) {
    objc_setAssociatedObject(base, key, value, .OBJC_ASSOCIATION_RETAIN)
}
