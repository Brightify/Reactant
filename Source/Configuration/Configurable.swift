//
//  Configurable.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

public protocol Configurable: class {
    /// See `Configuration` for more info.
    var reactantConfiguration: ReactantConfiguration { get set }
}

extension Configurable {

    /**
     * Reloads object's configuration. Essentially just calls `didSet` on its configuration.
     */
    public func reloadConfiguration() {
        let temp = reactantConfiguration
        reactantConfiguration = temp
    }

    /**
     * Applies passed `Configuration` to this object.
     * This function is destructive, but also returns itself to allow chaining.
     * - parameter configuration: new configuration to set to the object
     * - returns: self with new configuration set
     */
    public func with(configuration: ReactantConfiguration) -> Self {
        self.reactantConfiguration = configuration
        return self
    }
}
