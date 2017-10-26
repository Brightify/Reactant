//
//  UIStackView+ArrangedChildren.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
extension UIStackView {

    /**
     * Adds arranged subviews to the stack view that this method is called upon.
     * Convenience method working the same as `addArrangedSubview(_:)` but letting you pass multiple UIViews at once.
     * - parameter children: `UIView`s to be added as arranged subviews
     */
    @discardableResult
    public func arrangedChildren(_ children: UIView...) -> UIStackView {
        return arrangedChildren(children)
    }

    /**
     * Adds arranged subviews to the stack view that this method is called upon.
     * Convenience method working the same as `addArrangedSubview(_:)` but letting you pass an array of UIViews.
     * - parameter children: `UIView`s to be added as arranged subviews
     */
    @discardableResult
    public func arrangedChildren(_ children: [UIView]) -> UIStackView {
        children.forEach(addArrangedSubview)
        return self
    }
}
