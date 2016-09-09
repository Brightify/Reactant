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

private class CollapsibleConstraintsBox {
    var value: [(constraint: Constraint, action: ConstraintAction)]

    init(_ value: [(constraint: Constraint, action: ConstraintAction)]) {
        self.value = value
    }
}

private class CollapseAxisBox {
    var value: CollapseAxis

    init(_ value: CollapseAxis) {
        self.value = value
    }
}

public enum Visibility {
    case Visible
    case Hidden
    case Collapsed
}

public enum ConstraintAction {
    case SetConstant(visible: CGFloat, collapsed: CGFloat)
    case Install
    case Uninstall
}

public enum CollapseAxis {
    case Horizontal
    case Vertical
    case Both
}

public extension UIView {
    private struct AssociatedKey {
        static var collapseAxis: UInt8 = 0
        static var visibility: UInt8 = 0
        static var zeroWidthConstraints: UInt8 = 0
        static var zeroHeightConstraints: UInt8 = 0
        static var collapsibleConstraints: UInt8 = 0
    }

    public var rootView: UIView {
        if let superview = superview {
            return superview.rootView
        } else {
            return self
        }
    }

    public var collapseAxis: CollapseAxis {
        get {
            return associatedObject(self, key: &AssociatedKey.collapseAxis) {
                CollapseAxisBox(CollapseAxis.Vertical)
                }.value
        }
        set {
            let resetVisibility = visibility == .Collapsed && collapseAxis != newValue
            if resetVisibility {
                visibility = .Hidden
            }

            associateObject(self, key: &AssociatedKey.collapseAxis, value: CollapseAxisBox(newValue))

            if resetVisibility {
                visibility = .Collapsed
            }
        }
    }

    public var visibility: Visibility {
        get {
            return associatedObject(self, key: &AssociatedKey.visibility) {
                VisibilityBox(hidden ? .Hidden : .Visible)
                }.value
        }
        set {
            var collapseConstraints: [(constraint: Constraint, action: ConstraintAction)] = collapsibleConstraints
            switch collapseAxis {
            case .Horizontal:
                collapseConstraints.append((zeroWidthConstraint, .Install))
            case .Vertical:
                collapseConstraints.append((zeroHeightConstraint, .Install))
            case .Both:
                collapseConstraints.append((zeroWidthConstraint, .Install))
                collapseConstraints.append((zeroHeightConstraint, .Install))
            }

            alpha = newValue == .Visible ? 1 : 0
            if newValue == .Collapsed {
                for constraint in collapseConstraints {
                    switch constraint.action {
                    case .SetConstant(_, let collapsed):
                        constraint.constraint.updateOffset(collapsed)
                    case .Install:
                        constraint.constraint.install()
                    case .Uninstall:
                        constraint.constraint.uninstall()
                    }
                }
            } else {
                for constraint in collapseConstraints.reverse() {
                    switch constraint.action {
                    case .SetConstant(let visible, _):
                        constraint.constraint.updateOffset(visible)
                    case .Install:
                        constraint.constraint.uninstall()
                    case .Uninstall:
                        constraint.constraint.install()
                    }
                }
            }

            associateObject(self, key: &AssociatedKey.visibility, value: VisibilityBox(newValue))
        }
    }

    public var collapsibleConstraints: [(constraint: Constraint, action: ConstraintAction)] {
        get {
            return associatedObject(self, key: &AssociatedKey.collapsibleConstraints) {
                CollapsibleConstraintsBox([])
                }.value
        }
        set {
            let box = CollapsibleConstraintsBox(newValue)
            associateObject(self, key: &AssociatedKey.collapsibleConstraints, value: box)
        }
    }

    public func addCollapsibleConstraint(constraint: Constraint, action: ConstraintAction) {
        collapsibleConstraints = collapsibleConstraints.filter { $0.constraint !== constraint }
            .arrayByAppending((constraint: constraint, action: action))
    }

    private var zeroWidthConstraint: Constraint {
        return associatedObject(self, key: &AssociatedKey.zeroWidthConstraints) {
            var maybeConstraint: Constraint?
            snp_prepareConstraints { make in
                maybeConstraint = make.width.equalTo(0).constraint
            }
            guard let constraint = maybeConstraint else { fatalError("Could not create zero-width constraint!") }
            return constraint
        }
    }

    private var zeroHeightConstraint: Constraint {
        return associatedObject(self, key: &AssociatedKey.zeroHeightConstraints) {
            var maybeConstraint: Constraint?
            snp_prepareConstraints { make in
                maybeConstraint = make.height.equalTo(0).constraint
            }
            guard let constraint = maybeConstraint else { fatalError("Could not create zero-height constraint!") }
            return constraint
        }
    }
}
