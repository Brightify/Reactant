//
//  Reusable.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 1/24/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

public protocol Reusable: class {
    /**
     * Called during recyclation. Usually resets the Component's state.
     * NOTE: For more info see `Recycler`.
     */
    func prepareForReuse()
}
