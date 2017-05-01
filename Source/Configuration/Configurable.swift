//
//  Configurable.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

public protocol Configurable: class {
    
    var configuration: Configuration { get set }
}

extension Configurable {
    
    /// Calls didSet on configuration.
    public func reloadConfiguration() {
        let temp = configuration
        configuration = temp
    }
    
    /// Applies configuration to this object and returns it to allow chaining.
    public func with(configuration: Configuration) -> Self {
        self.configuration = configuration
        return self
    }
}
