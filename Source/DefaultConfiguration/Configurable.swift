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
    
    public func reloadConfiguration() {
        let temp = configuration
        configuration = temp
    }
    
    public func with(configuration: Configuration) -> Self {
        self.configuration = configuration
        return self
    }
}
