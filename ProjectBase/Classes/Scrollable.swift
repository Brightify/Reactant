//
//  Scrollable.swift
//  Pods
//
//  Created by Matouš Hýbl on 7/13/16.
//
//

import UIKit

protocol Scrollable {
    func scrollToTop(animated: Bool)
}

extension Scrollable {
    func scrollToTop() {
        scrollToTop(true)
    }
}

extension UIScrollView: Scrollable {
    func scrollToTop(animated: Bool) {
        let inset = contentInset
        setContentOffset(CGPointMake(-inset.left, -inset.top), animated: animated)
    }
}