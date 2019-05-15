//
//  UIView+Utils.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UIView {

    /**
     * Adds subviews to the view that this method is called upon.
     * Convenience method working the same as `addSubview(_:)` but letting you pass multiple UIViews at once.
     * - parameter children: `UIView`s to be added as subviews
     * ## Example
     * ```
     * override func loadView() {
     *   children(
     *     titleLabel,
     *     loginContainer.children(
     *       loginTextField,
     *       passwordTextField,
     *     ),
     *     passwordRecoveryButton
     *   )
     * }
     * ```
     */
    @discardableResult
    /*public*/ func children(_ children: UIView...) -> UIView {
        return self.children(children)
    }

    /**
     * Adds subviews to the view that this method is called upon.
     * Convenience method working the same as `addSubview(_:)` but letting you pass an array of UIViews.
     * - parameter children: `UIView`s to be added as subviews
     * ## Example
     * ```
     * override func loadView() {
     *   children(
     *     titleLabel,
     *     loginContainer.children(
     *       loginTextField,
     *       passwordTextField,
     *     ),
     *     passwordRecoveryButton
     *   )
     * }
     * ```
     */
    @discardableResult
    /*public*/ func children(_ children: [UIView]) -> UIView {
        children.forEach(addSubview)
        return self
    }

    /**
     * Variable pointing to view's superview if there is one or self if there isn't.
     * Usually used in Controller when passing `Component.componentState` to the corresponding RootView.
     */
    /*public*/ var rootView: UIView {
        if let superview = superview {
            return superview.rootView
        } else {
            return self
        }
    }
}
#endif
