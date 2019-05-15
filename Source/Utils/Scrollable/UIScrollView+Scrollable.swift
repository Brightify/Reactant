//
//  UIScrollView+Scrollable.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UIScrollView: Scrollable {

    public func scrollToTop(animated: Bool) {
        let inset = contentInset
        setContentOffset(CGPoint(x: -inset.left, y: -inset.top), animated: animated)
    }
}
#endif
