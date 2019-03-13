//
//  Invalidable.swift
//  Hyperdrive
//
//  Created by Tadeas Kriz on 12/03/2019.
//  Copyright © 2019 Brightify. All rights reserved.
//

import Foundation

public protocol Invalidable: AnyObject {
    /**
     * Used for manually calling `Component.update()`. As opposed to `componentState = componentState` this preserves `previousComponentState`.
     * - NOTE: For most situations update called automatically by changing `Component.componentState` should suffice.
     *  However if you're dealing with **reference type** as `componentState`, manually calling `invalidate()` lets you update manually.
     */
    func invalidate()
}
