//
//  Scrollable.swift
//  Pods
//
//  Created by Matouš Hýbl on 7/13/16.
//
//

import UIKit

open protocol Scrollable {
    func scrollToTop(animated: Bool)
}

open extension Scrollable {
    open func scrollToTop() {
        scrollToTop(animated: true)
    }
}

extension UIScrollView: Scrollable {
    open func scrollToTop(animated: Bool) {
        let inset = contentInset
        setContentOffset(CGPoint(x: -inset.left, y: -inset.top), animated: animated)
    }
}
