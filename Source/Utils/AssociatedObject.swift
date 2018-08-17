//
//  AssociatedObject.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public enum AssociationPolicy {
    /**< Specifies a weak reference to the associated object. */
    case assign

    /**< Specifies a strong reference to the associated object.
     *   The association is not made atomically. */
    case retainNonatomic

    /**< Specifies that the associated object is copied.
     *   The association is not made atomically. */
    case copyNonatomic

    /**< Specifies a strong reference to the associated object.
     *   The association is made atomically. */
    case retain

    /**< Specifies that the associated object is copied.
     *   The association is made atomically. */
    case copy

    var objcValue: objc_AssociationPolicy {
        switch self {
        case .assign:
            return .OBJC_ASSOCIATION_ASSIGN
        case .retainNonatomic:
            return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        case .copyNonatomic:
            return .OBJC_ASSOCIATION_COPY_NONATOMIC
        case .retain:
            return .OBJC_ASSOCIATION_RETAIN
        case .copy:
            return .OBJC_ASSOCIATION_COPY
        }
    }
}

public func associatedObject<T>(_ base: Any, key: UnsafePointer<UInt8>, defaultValue: @autoclosure () -> T, policy: AssociationPolicy = .retain) -> T {
    if let associated = objc_getAssociatedObject(base, key) as? T {
        return associated
    } else {
        let value = defaultValue()
        associateObject(base, key: key, value: value, policy: policy)
        return value
    }
}

public func associatedObject<T>(_ base: Any, key: UnsafePointer<UInt8>, policy: AssociationPolicy = .retain, initializer: () -> T) -> T {
    if let associated = objc_getAssociatedObject(base, key) as? T {
        return associated
    } else {
        let defaultValue = initializer()
        associateObject(base, key: key, value: defaultValue, policy: policy)
        return defaultValue
    }
}

public func associateObject<T>(_ base: Any, key: UnsafePointer<UInt8>, value: T, policy: AssociationPolicy = .retain) {
    objc_setAssociatedObject(base, key, value, policy.objcValue)
}

public func removeAssociatedObject(_ base: Any, key: UnsafePointer<UInt8>) {
    objc_setAssociatedObject(base, key, nil, .OBJC_ASSOCIATION_ASSIGN)
}
