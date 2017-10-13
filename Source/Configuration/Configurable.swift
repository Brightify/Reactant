//
//  Configurable.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

public protocol Configurable: class {
    /// See `Configuration` for more info.
    var configuration: Configuration { get set }
}

extension Configurable {

    /**
     * Reloads object's configuration. Essentially just calls `didSet` on its configuration.
     */
    public func reloadConfiguration() {
        let temp = configuration
        configuration = temp
    }

    /**
     * Applies passed `Configuration` to this object.
     * This function is destructive, but also returns itself to allow chaining.
     * - parameter configuration: new configuration to set to the object
     * - returns: self with new configuration set
     */
    public func with(configuration: Configuration) -> Self {
        self.configuration = configuration
        return self
    }
}
