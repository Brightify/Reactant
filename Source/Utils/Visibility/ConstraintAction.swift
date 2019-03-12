//
//  ConstraintAction.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreGraphics

/**
 * ## Set Constant
 * Sets constants to `Constraint` in its visible and collapsed form.
 * ## Install
 * Activates the constraint.
 * ## Uninstall
 * Deactivates the constraint.
 * - NOTE: Deactivated constraint is not taken into account when AutoLayouting.
 */
public enum ConstraintAction {
    case setConstant(visible: CGFloat, collapsed: CGFloat)
    case install
    case uninstall
}
