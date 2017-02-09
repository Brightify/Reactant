//
//  Rule.swift
//  Reactant
//
//  Created by Filip Dolnik on 20.11.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Result

public struct Rule<T, E: Error> {
    
    public let validate: (T) -> E?
    
    public init(validate: @escaping (T) -> E?) {
        self.validate = validate
    }
    
    public func test(_ value: T) -> Bool {
        return validate(value) == nil
    }
    
    public func run(_ value: T) -> Result<T, E> {
        if let error = validate(value) {
            return .failure(error)
        } else {
            return .success(value)
        }
    }
}
