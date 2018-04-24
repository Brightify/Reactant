//
//  Configuration.swift
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
    // XXX: This code is here due to bug in Swift/Xcode where types inside extensions depend on compilation order
    public typealias Style = StyleConfiguration

    /// Global configuration instance. It's used as a default configuration in every component throughout Reactant.
    public static var global = Configuration()
    
    private var data: [Int: Any] = [:]

    /** 
     * Initializes configuration as a combination of provided configurations.
     * If no configuration is provided, an empty Configuration is created.
     * - parameter copy: variadic parameter, passing in multiple `Configuration`s merges them into one
     */
    public init(copy: Configuration...) {
        self.data = copy.reduce([:]) { acc, value in
            var dictionary = acc
            value.data.forEach { dictionary[$0] = $1 }
            return dictionary
        }
    }

    /**
     * Standard setter for a value for passed property.
     * - parameter property: property to which you want to set the `Configuration`
     * - parameter value: value to set for specified property
     */
    public func set<T>(_ property: Property<T>, to value: T) {
        data[property.id] = value
    }

    /**
     * Standard getter for configuration properties.
     * - parameter property: property from which you want to get the `Configuration`
     * - returns: value for specified property or a property's default value if it hasn't been set in this `Configuration`
     */
    public func get<T>(valueFor property: Property<T>) -> T {
        return (data[property.id] as? T) ?? property.defaultValue
    }
}
