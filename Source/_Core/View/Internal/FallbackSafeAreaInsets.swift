//
//  FallbackSafeAreaInsets.swift
//  Reactant
//
//  Created by Tadeas Kriz on 12/9/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
import UIKit

#if ENABLE_SAFEAREAINSETS_FALLBACK
private class FallbackSafeAreaConstraints {
    var top: NSLayoutConstraint
    var left: NSLayoutConstraint
    var bottom: NSLayoutConstraint
    var right: NSLayoutConstraint

    init(top: NSLayoutConstraint, left: NSLayoutConstraint, bottom: NSLayoutConstraint, right: NSLayoutConstraint) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
}

public extension UIView {
    private struct AssociateKeys {
        static var fallback_safeAreaInsets: UInt8 = 0
        static var fallback_safeAreaConstraints: UInt8 = 0
        static var fallback_safeAreaLayoutGuide: UInt8 = 0
    }

    private var isFallbackEnabled: Bool {
        if #available(iOS 11.0, *) {
            return false
        } else {
            return true
        }
    }

    public internal(set) var fallback_safeAreaInsets: UIEdgeInsets {
        get {
            return associatedObject(self, key: &AssociateKeys.fallback_safeAreaInsets, defaultValue: .zero)
        }
        set {
            guard fallback_safeAreaInsets != newValue else {
                return
            }
            associateObject(self, key: &AssociateKeys.fallback_safeAreaInsets, value: newValue)

            fallback_updateSafeAreaLayoutGuideConstraintsIfNecessary()

            subviews.forEach {
                $0.fallback_computeSafeAreaInsets()
            }
        }
    }


    private var fallback_safeAreaConstraints: FallbackSafeAreaConstraints? {
        get {
            return associatedObject(self, key: &AssociateKeys.fallback_safeAreaConstraints, defaultValue: nil)
        }
        set {
            associateObject(self, key: &AssociateKeys.fallback_safeAreaConstraints, value: newValue)
        }
    }

    public var fallback_safeAreaLayoutGuide: UILayoutGuide {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return safeAreaLayoutGuide
        }

        return associatedObject(self, key: &AssociateKeys.fallback_safeAreaLayoutGuide) {
            let guide = UILayoutGuide()

            addLayoutGuide(guide)
            guide.identifier = "Fallback_UIViewSafeAreaLayoutGuide"

            let top = guide.topAnchor.constraint(equalTo: topAnchor)
            top.identifier = "Fallback_UIViewSafeAreaLayoutGuide-top"
            let left = guide.leftAnchor.constraint(equalTo: leftAnchor)
            left.identifier = "Fallback_UIViewSafeAreaLayoutGuide-left"
            let bottom = guide.bottomAnchor.constraint(equalTo: bottomAnchor)
            bottom.identifier = "Fallback_UIViewSafeAreaLayoutGuide-bottom"
            let right = guide.rightAnchor.constraint(equalTo: rightAnchor)
            right.identifier = "Fallback_UIViewSafeAreaLayoutGuide-right"

            NSLayoutConstraint.activate([top, left, bottom, right])

            fallback_safeAreaConstraints = FallbackSafeAreaConstraints(top: top, left: left, bottom: bottom, right: right)

            fallback_updateSafeAreaLayoutGuideConstraintsIfNecessary()

            return guide
        }
    }

    internal func fallback_updateSafeAreaLayoutGuideConstraintsIfNecessary() {
        guard isFallbackEnabled else { return }

        guard let constraints = fallback_safeAreaConstraints else { return }
        let insets = fallback_safeAreaInsets

        constraints.top.constant = insets.top
        constraints.left.constant = insets.left
        constraints.bottom.constant = -insets.bottom
        constraints.right.constant = -insets.right
    }

    internal func fallback_computeSafeAreaInsets() {
        guard isFallbackEnabled else { return }

        guard let superview = superview else { return }

        let superviewInsets = superview.fallback_safeAreaInsets

        func clamp(min: CGFloat, value: CGFloat, max: CGFloat) -> CGFloat {
            return Swift.max(min, Swift.min(value, max))
        }

        let newInsets = UIEdgeInsets(
            top: clamp(min: 0, value: superviewInsets.top - frame.origin.y, max: frame.height),
            left: clamp(min: 0, value: superviewInsets.left - frame.origin.x, max: frame.width),
            bottom: clamp(min: 0, value: (frame.origin.y + frame.height) - (superview.frame.height - superviewInsets.bottom), max: frame.height),
            right: clamp(min: 0, value: (frame.origin.x + frame.width) - (superview.frame.width - superviewInsets.right), max: frame.width))

        fallback_safeAreaInsets = newInsets
    }
}

extension UIViewController {
    internal func fallback_setViewSafeAreaInests() {
        if #available(*, iOS 10) {
            view.fallback_safeAreaInsets = UIEdgeInsets(
                top: topLayoutGuide.length,
                left: 0,
                bottom: bottomLayoutGuide.length,
                right: 0)
        }
    }
}
#endif
#endif
