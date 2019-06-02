//
//  NSAttributedString+Attribute.swift
//  Reactant
//
//  Created by Tadeas Kriz on 5/2/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
    let mutableString = NSMutableAttributedString(attributedString: lhs)
    mutableString.append(rhs)
    return mutableString
}

public func + (lhs: String, rhs: NSAttributedString) -> NSAttributedString {
    return lhs.attributed() + rhs
}

public func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
    return lhs + rhs.attributed()
}

public extension String {

    /**
     * Allows you to easily create an `NSAttributedString` out of regular `String`
     * For available attributes see `Attribute`.
     * parameter attributes: passed attributes with which NSAttributedString is created
     * ## Example
     * ```
     * let attributedString = "Beautiful String".attributed(.kern(1.2), .strokeWidth(1), .strokeColor(.red))
     * ```
     */
    func attributed(_ attributes: [Attribute]) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: attributes.toDictionary())
    }

    /**
     * Allows you to easily create an `NSAttributedString` out of regular `String`
     * For available attributes see `Attribute`.
     * parameter attributes: passed attributes with which NSAttributedString is created
     * ## Example
     * ```
     * let attributedString = "Beautiful String".attributed(.kern(1.2), .strokeWidth(1), .strokeColor(.red))
     * ```
     */
    func attributed(_ attributes: Attribute...) -> NSAttributedString {
        return attributed(attributes)
    }
}
#endif
