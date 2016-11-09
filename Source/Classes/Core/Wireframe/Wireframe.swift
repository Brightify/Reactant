//
//  Wireframe.swift
//  Reactant
//
//  Created by Filip Dolnik on 09.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public class Wireframe {
    
}

extension Wireframe {
    
    public func create<T>(factory: (FutureControllerProvider<T>) -> T) -> T {
        let futureControllerProvider = FutureControllerProvider<T>()
        let controller = factory(futureControllerProvider)
        futureControllerProvider.controller = controller
        return controller
    }
}
