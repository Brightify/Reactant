//
//  UIView+Visibility.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import SnapKit

public extension View {
    
    private struct AssociatedKey {
        static var collapseAxis: UInt8 = 0
        static var visibility: UInt8 = 0
        static var zeroWidthConstraints: UInt8 = 0
        static var zeroHeightConstraints: UInt8 = 0
        static var collapsibleConstraints: UInt8 = 0
    }

    /**
     * Axis on which setting `visibility` to `.collapsed` should the view collapse.
     * - NOTE: The **UIView** will still retain the dimension of the other axis
     */
    @objc
    public var collapseAxis: CollapseAxis {
        get {
            return associatedObject(self, key: &AssociatedKey.collapseAxis, defaultValue: .vertical)
        }
        set {
            let resetVisibility = visibility == .collapsed && collapseAxis != newValue
            if resetVisibility {
                visibility = .hidden
            }
            
            associateObject(self, key: &AssociatedKey.collapseAxis, value: newValue)
            
            if resetVisibility {
                visibility = .collapsed
            }
        }
    }

    /**
     * Sets the visibility of the **UIView**, honoring `collapseAxis`.
     *
     * Recommended to use instead of standard `isHidden`.
     * - NOTE: See `Visibility` for info about available values.
     */
    @objc
    public var visibility: Visibility {
        get {
            return associatedObject(self, key: &AssociatedKey.visibility, defaultValue: isHidden ? .hidden : .visible)
        }
        set {
            var collapseConstraints = collapsibleConstraints
            switch collapseAxis {
            case .horizontal:
                collapseConstraints.append((zeroWidthConstraint, .install))
            case .vertical:
                collapseConstraints.append((zeroHeightConstraint, .install))
            case .both:
                collapseConstraints.append((zeroWidthConstraint, .install))
                collapseConstraints.append((zeroHeightConstraint, .install))
            }

            #if os(iOS)
                alpha = newValue == .visible ? 1 : 0
            #elseif os(macOS)
                alphaValue = newValue == .visible ? 1 : 0
            #endif
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
            
            associateObject(self, key: &AssociatedKey.visibility, value: newValue)
        }
    }

    /**
     * Collection of tuples (Constraint, ConstraintAction) holding all collapsible constraints.
     * - ATTENTION: We recommend method `addCollapsible(constraint:action:)` for adding constraints to it.
     */
    public var collapsibleConstraints: [(constraint: Constraint, action: ConstraintAction)] {
        get {
            return associatedObject(self, key: &AssociatedKey.collapsibleConstraints, defaultValue: [])
        }
        set {
            associateObject(self, key: &AssociatedKey.collapsibleConstraints, value: newValue)
        }
    }

    /**
     * Convenience method for adding a collapsible constraint into `collapsibleConstraints` variable.
     * - parameter constraint: `Constraint` to be added as collapsible
     * - parameter action: determines the action of the constraint
     * - NOTE: For available actions see `ConstraintAction`.
     */
    public func addCollapsible(constraint: Constraint, action: ConstraintAction) {
        collapsibleConstraints = collapsibleConstraints.filter { $0.constraint !== constraint }
            .arrayByAppending((constraint: constraint, action: action))
    }
    
    private var zeroWidthConstraint: Constraint {
        return associatedObject(self, key: &AssociatedKey.zeroWidthConstraints) {
            var maybeConstraint: Constraint?
            snp.prepareConstraints { make in
                maybeConstraint = make.width.equalTo(0).constraint
            }
            guard let constraint = maybeConstraint else { fatalError("Could not create zero-width constraint!") }
            return constraint
        }
    }
    
    private var zeroHeightConstraint: Constraint {
        return associatedObject(self, key: &AssociatedKey.zeroHeightConstraints) {
            var maybeConstraint: Constraint?
            snp.prepareConstraints { make in
                maybeConstraint = make.height.equalTo(0).constraint
            }
            guard let constraint = maybeConstraint else { fatalError("Could not create zero-height constraint!") }
            return constraint
        }
    }
}
