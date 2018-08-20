//
//  NSAttributedString+Attribute.swift
//  Reactant
//
//  Created by Tadeas Kriz on 5/2/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

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

extension String {

    /**
     * Allows you to easily create an `NSAttributedString` out of regular `String`
     * For available attributes see `Attribute`.
     * parameter attributes: passed attributes with which NSAttributedString is created
     * ## Example
     * ```
     * let attributedString = "Beautiful String".attributed(.kern(1.2), .strokeWidth(1), .strokeColor(.red))
     * ```
     */
    public func attributed(_ attributes: [Attribute]) -> NSAttributedString {
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
    public func attributed(_ attributes: Attribute...) -> NSAttributedString {
        return attributed(attributes)
    }

    /**
     * Allows you to easily attribute particular range in an NSAttributedString
     * For available attributes see `Attribute`.
     * parameter attributes: passed attributes with which are applied to the range
     * parameter range: range to which the attributes are applied
     */
    public func attributed(_ attributes: [Attribute], range: NSRange) -> NSAttributedString {
        let mutable = NSMutableAttributedString(string: self)
        mutable.addAttributes(attributes, to: range)

        return mutable
    }

    /**
     * Allows you to easily attribute particular range in an NSAttributedString
     * For available attributes see `Attribute`.
     * parameter attributes: passed attributes with which are applied to the range
     * parameter range: range to which the attributes are applied
     */
    public func attributed(_ attributes: Attribute..., range: NSRange) -> NSAttributedString {
        return attributed(attributes, range: range)
    }
}

extension NSAttributedString {
    /**
     * Allows you to easily attribute particular range in an NSAttributedString
     * For available attributes see `Attribute`.
     * parameter attributes: passed attributes with which are applied to the range
     * parameter range: range to which the attributes are applied
     */
    public func attributed(_ attributes: [Attribute], range: NSRange) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: self)
        mutable.addAttributes(attributes, to: range)

        return mutable
    }

    /**
     * Allows you to easily attribute particular range in an NSAttributedString
     * For available attributes see `Attribute`.
     * parameter attributes: passed attributes with which are applied to the range
     * parameter range: range to which the attributes are applied
     */
    public func attributed(_ attributes: Attribute..., range: NSRange) -> NSAttributedString {
        return attributed(attributes, range: range)
    }
}

extension NSMutableAttributedString {
    /**
     * Allows you to add attributes to particular range in an NSAttributedString
     * For available attributes see `Attribute`.
     * parameter attributes: passed attributes with which are applied to the range
     * parameter range: range to which the attributes are applied
     */
    public func addAttributes(_ attributes: [Attribute], to range: NSRange) {
        addAttributes(attributes.toDictionary(), range: range)
    }

    /**
     * Allows you to add attributes to particular range in an NSAttributedString
     * For available attributes see `Attribute`.
     * parameter attributes: passed attributes with which are applied to the range
     * parameter range: range to which the attributes are applied
     */
    public func attributed(_ attributes: Attribute..., to range: NSRange) {
        addAttributes(attributes, to: range)
    }
}
