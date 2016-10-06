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
    case visible
    case hidden
    case collapsed
}

public enum ConstraintAction {
    case setConstant(visible: CGFloat, collapsed: CGFloat)
    case install
    case uninstall
}

public enum CollapseAxis {
    case horizontal
    case vertical
    case both
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
                CollapseAxisBox(CollapseAxis.vertical)
                }.value
        }
        set {
            let resetVisibility = visibility == .collapsed && collapseAxis != newValue
            if resetVisibility {
                visibility = .hidden
            }

            associateObject(self, key: &AssociatedKey.collapseAxis, value: CollapseAxisBox(newValue))

            if resetVisibility {
                visibility = .collapsed
            }
        }
    }

    public var visibility: Visibility {
        get {
            return associatedObject(self, key: &AssociatedKey.visibility) {
                VisibilityBox(isHidden ? .hidden : .visible)
                }.value
        }
        set {
            var collapseConstraints: [(constraint: Constraint, action: ConstraintAction)] = collapsibleConstraints
            switch collapseAxis {
            case .horizontal:
                collapseConstraints.append((zeroWidthConstraint, .install))
            case .vertical:
                collapseConstraints.append((zeroHeightConstraint, .install))
            case .both:
                collapseConstraints.append((zeroWidthConstraint, .install))
                collapseConstraints.append((zeroHeightConstraint, .install))
            }

            alpha = newValue == .visible ? 1 : 0
            if newValue == .collapsed {
                for constraint in collapseConstraints {
                    switch constraint.action {
                    case .setConstant(_, let collapsed):
                        constraint.constraint.update(offset: collapsed)
                    case .install:
                        constraint.constraint.activate()
                    case .uninstall:
                        constraint.constraint.deactivate()
                    }
                }
            } else {
                for constraint in collapseConstraints.reversed() {
                    switch constraint.action {
                    case .setConstant(let visible, _):
                        constraint.constraint.update(offset: visible)
                    case .install:
                        constraint.constraint.deactivate()
                    case .uninstall:
                        constraint.constraint.activate()
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

    public func addCollapsible(constraint: Constraint, action: ConstraintAction) {
        collapsibleConstraints = collapsibleConstraints.filter { $0.constraint !== constraint }
            .arrayByAppending((constraint: constraint, action: action))
    }

    private var zeroWidthConstraint: Constraint {
        return associatedObject(self, key: &AssociatedKey.zeroWidthConstraints) {
            var maybeConstraint: Constraint?
            snp.prepareConstraints { make in
                maybeConstraint = make.width.equalToSuperview().constraint
            }
            guard let constraint = maybeConstraint else { fatalError("Could not create zero-width constraint!") }
            return constraint
        }
    }

    private var zeroHeightConstraint: Constraint {
        return associatedObject(self, key: &AssociatedKey.zeroHeightConstraints) {
            var maybeConstraint: Constraint?
            snp.prepareConstraints { make in
                maybeConstraint = make.height.equalToSuperview().constraint
            }
            guard let constraint = maybeConstraint else { fatalError("Could not create zero-height constraint!") }
            return constraint
        }
    }
}
