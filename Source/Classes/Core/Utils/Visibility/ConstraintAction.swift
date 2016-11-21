//
//  ConstraintAction.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import UIKit

public enum ConstraintAction {
    case setConstant(visible: CGFloat, collapsed: CGFloat)
    case install
    case uninstall
}
