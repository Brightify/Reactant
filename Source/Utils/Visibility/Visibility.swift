//
//  Visibility.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//
import Foundation

/**
 * ## Visible
 * View is fully visible with no modifications.
 * ## Hidden
 * View is not visible, but its dimensions stay the same.
 * ## Collapsed
 * View is not visible and is squashed on either X or Y axis.
 */
@objc
public enum Visibility: Int {
    case visible
    case hidden
    case collapsed
}
