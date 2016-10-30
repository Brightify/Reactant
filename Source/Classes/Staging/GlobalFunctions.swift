//
//  GlobalFunctions.swift
//  SwiftKit
//
//  Created by Tadeas Kriz on 13/10/15.
//  Copyright © 2015 Tadeas Kriz. All rights reserved.
//

import Foundation

public func inferredType<T>() -> T.Type {
    return T.self
}

public func associatedObject<T: AnyObject>(_ base: AnyObject, key: UnsafePointer<UInt8>, initializer: () -> T) -> T {
    if let associated = objc_getAssociatedObject(base, key) as? T {
        return associated
    }
    
    let associated = initializer()
    objc_setAssociatedObject(base, key, associated, .OBJC_ASSOCIATION_RETAIN)
    return associated
}

public func associateObject<T: AnyObject>(_ base: AnyObject, key: UnsafePointer<UInt8>, value: T) {
    objc_setAssociatedObject(base, key, value, .OBJC_ASSOCIATION_RETAIN)
}
