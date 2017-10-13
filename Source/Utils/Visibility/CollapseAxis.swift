//
//  CollapseAxis.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//
import Foundation

/**
 * Axis on which a **UIView** should collapse.
 * ## Horizontal
 * **UIView** collapses on horizontal axis (i.e. its width is squashed).
 * ## Vertical
 * **UIView** collapses on vertical axis (i.e. its height is squashed).
 * ## Both
 * **UIView** collapses on both axes (i.e. both its weight and height are squashed).
 */
@objc
public enum CollapseAxis: Int {
    case horizontal
    case vertical
    case both
}
