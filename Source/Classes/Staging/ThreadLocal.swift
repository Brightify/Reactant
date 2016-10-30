//
//  ThreadLocal.swift
//  SwiftKit
//
//  Created by Tadeas Kriz on 13/10/15.
//  Copyright © 2015 Tadeas Kriz. All rights reserved.
//

import Foundation

open class ThreadLocal<T: AnyObject>: ThreadLocalParametrized<Void, T> {
    
    public convenience init(create: @escaping () -> T) {
        self.init(id: UUID().uuidString, create: create)
    }
    
    public override init(id: String, create: @escaping () -> T) {
        super.init(id: id, create: create)
    }
    
    open func get() -> T {
        return super.get()
    }
}

open class ThreadLocalParametrized<PARAMS, T: AnyObject> {
    fileprivate let id: String
    fileprivate let create: (PARAMS) -> T
    
    public convenience init(create: @escaping (PARAMS) -> T) {
        self.init(id: UUID().uuidString, create: create)
    }
    
    public init(id: String, create: @escaping (PARAMS) -> T) {
        self.id = id
        self.create = create
    }
    
    open func get(_ parameters: PARAMS) -> T {
        if let cachedObject = Thread.current.threadDictionary[id] as? T {
            return cachedObject
        } else {
            let newObject = create(parameters)
            set(newObject)
            return newObject
        }
    }
    
    open func set(_ value: T) {
        Thread.current.threadDictionary[id] = value
    }
    
    open func remove() {
        Thread.current.threadDictionary.removeObject(forKey: id)
    }
    
}
