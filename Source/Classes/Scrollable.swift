//
//  Scrollable.swift
//  Pods
//
//  Created by Matouš Hýbl on 7/13/16.
//
//

import UIKit

public protocol Scrollable {
    func scrollToTop(animated: Bool)
}

public extension Scrollable {
    public func scrollToTop() {
        scrollToTop(true)
    }
}

extension UIScrollView: Scrollable {
    public func scrollToTop(animated: Bool) {
        let inset = contentInset
        setContentOffset(CGPointMake(-inset.left, -inset.top), animated: animated)
    }
}