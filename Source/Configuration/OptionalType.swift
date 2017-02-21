//
//  OptionalType.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

public protocol OptionalType {
    
    static var null: Self { get }
}

extension Optional: OptionalType {
    
    public static var null: Optional<Wrapped> {
        return nil
    }
}
