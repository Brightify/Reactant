//
//  UIView+Visibility.swift
//  Pods
//
//  Created by Matouš Hýbl on 7/27/16.
//
//

import SnapKit
import SwiftKitStaging

private class VisibilityBox {
    var value: Visibility

    init(_ value: Visibility) {
        self.value = value
    }
}

public enum Visibility {
    case Visible
    case Hidden
    case Gone
}

public extension UIView {
    private struct AssociatedKey {
        static var visibility: UInt8 = 0
        static var constraints: UInt8 = 0
    }

    public var rootView: UIView {
        if let superview = superview {
            return superview.rootView
        } else {
            return self
        }
    }

    public var visibility: Visibility {
        get {
            return associatedObject(self, key: &AssociatedKey.visibility) {
                VisibilityBox(hidden ? .Hidden : .Visible)
                }.value
        }
        set {
            switch newValue {
            case .Gone:
                zeroHeightConstraint.install()
                alpha = 0
            case .Hidden:
                zeroHeightConstraint.uninstall()
                alpha = 0
            case .Visible:
                zeroHeightConstraint.uninstall()
                alpha = 1
            }
            associateObject(self, key: &AssociatedKey.visibility, value: VisibilityBox(newValue))
        }
    }

    private var zeroHeightConstraint: Constraint {
        return associatedObject(self, key: &AssociatedKey.constraints) {
            var maybeConstraint: Constraint?
            snp_makeConstraints { make in
                maybeConstraint = make.height.equalTo(0).constraint
            }
            guard let constraint = maybeConstraint else { fatalError("Could not create zero-height constraint!") }
            return constraint
        }
    }
}
