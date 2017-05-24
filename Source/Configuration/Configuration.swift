//
//  DefaultConfiguration.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

/**
 * A container for properties. This class is intended for global setup of Reactant internals. At the same time it can be
 * instantiated for multiple configurations (for example each part of application can have different background color).
 *
 * Reactant comes with prebuilt properties which you can find in extensions to the Properties struct. It's recommended 
 * to add any new property into the Properties struct via an extension to keep properties easily discoverable via auto-complete.
 */
public final class Configuration {

    /// Global configuration instance. It's used as a default configuration in every throughout Reactant.
    public static var global = Configuration()
    
    private var data: [Int: Any] = [:]

    /** 
     * Initializes configuration as a merge of provided configurations. 
     * If no configuration is provided, an empty Configuration is created.
     */
    public init(copy: Configuration...) {
        self.data = copy.reduce([:]) { acc, value in
            var dictionary = acc
            value.data.forEach { dictionary[$0] = $1 }
            return dictionary
        }
    }

    /// Sets a value for a property.
    public func set<T>(_ property: Property<T>, to value: T) {
        data[property.id] = value
    }

    /// Returns a value for specified property or a property's default value if it hasn't been set in this Configuration.
    public func get<T>(valueFor property: Property<T>) -> T {
        return (data[property.id] as? T) ?? property.defaultValue
    }
}
