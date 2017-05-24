//
//  Property.swift
//  Reactant
//
//  Created by Filip Dolnik on 14.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

/**
 * A definition of a configurable property. It defines its type and a default value. 
 */
public struct Property<T> {
    
    public let id: Int
    public let defaultValue: T
    
    public init(defaultValue: T) {
        id = PropertyIdProvider.nextId()
        self.defaultValue = defaultValue
    }
}

extension Property where T: OptionalType {
    public init() {
        self.init(defaultValue: T.null)
    }
}

private struct PropertyIdProvider {
    
    private static var lastUsedId = -1
    
    private static let syncQueue = DispatchQueue(label: "PropertyIdProvider_syncQueue")
    
    fileprivate static func nextId() -> Int {
        return syncQueue.sync {
            lastUsedId += 1
            return lastUsedId
        }
    }
}
