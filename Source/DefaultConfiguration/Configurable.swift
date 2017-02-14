//
//  Configurable.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

public protocol Configurable {
    
    var configuration: Configuration { get set }
}

extension Configurable {
    
    public mutating func with(configuration: Configuration) -> Self {
        self.configuration = configuration
        return self
    }
}
