//
//  PercentUtils.swift
//  Reactant
//
//  Created by Tadeas Kriz on 24/01/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import CoreGraphics

postfix operator %

/// Returns input / 100.
public postfix func %(input: CGFloat) -> CGFloat {
    return input / 100
}

