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
        
    public init(copy: Configuration...) {
        self.data = copy.map { $0.data }.reduce([:]) { acc, value in
            var dictionary = acc
            value.forEach { dictionary[$0] = $1 }
            return dictionary
        }
    }
    
    public func set<T>(_ property: Property<T>, to value: T) {
        data[property.id] = value
    }
    
    public func get<T>(valueFor property: Property<T>) -> T {
        return (data[property.id] as? T) ?? property.defaultValue
    }
}
