//
//  DefaultConfiguration.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

public final class Configuration {
    
    public static var global = Configuration()
    
    private var data: [Int: Any] = [:]
    
    public init() {
    }
    
    public func set<T>(value: T, for property: Property<T>) {
        data[property.id] = value
    }
    
    public func get<T>(valueFor property: Property<T>) -> T {
        return (data[property.id] as? T) ?? property.defaultValue
    }
}
