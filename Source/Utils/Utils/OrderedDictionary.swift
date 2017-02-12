//
//  OrderedDictionary.swift
//  Reactant
//
//  Created by Matouš Hýbl on 8/2/16.
//  Copyright © 2016 Ticketportal. All rights reserved.
//

// TODO
import Foundation
// OrderedDictionary behaves like a Dictionary except that it maintains
//  the insertion order of the keys, so iteration order matches insertion
//  order.
struct OrderedDictionary<KeyType:Hashable, ValueType> {
    fileprivate(set) var dictionary: Dictionary<KeyType, ValueType>
    fileprivate(set) var keys: Array<KeyType>
    
    init() {
        dictionary = [:]
        keys = []
    }
    
    init(minimumCapacity: Int) {
        dictionary = Dictionary<KeyType, ValueType>(minimumCapacity:minimumCapacity)
        keys = Array<KeyType>()
    }
    
    init(_ dictionary: Dictionary<KeyType, ValueType>) {
        self.dictionary = dictionary
        self.keys = dictionary.keys.map { $0 }
    }
    
    init(_ array: [(KeyType, ValueType)]) {
        var result = OrderedDictionary<KeyType, ValueType>()
        for (key, value) in array {
            result[key] = value
        }
        self = result
    }
    
    subscript(key: KeyType) -> ValueType? {
        get {
            return dictionary[key]
        }
        set {
            if newValue == nil {
                self.removeValueForKey(key)
            } else {
                _ = self.updateValue(newValue!, forKey: key)
            }
        }
    }
    
    mutating func updateValue(_ value: ValueType, forKey key: KeyType) -> ValueType? {
        let oldValue = dictionary.updateValue(value, forKey: key)
        if oldValue == nil {
            keys.append(key)
        }
        return oldValue
    }
    
    mutating func removeValueForKey(_ key: KeyType) {
        keys = keys.filter { $0 != key }
        dictionary.removeValue(forKey: key)
    }
    
    mutating func removeAll(_ keepCapacity: Int) {
        keys = []
        dictionary = Dictionary<KeyType, ValueType>(minimumCapacity: keepCapacity)
    }
    
    var count: Int { get { return dictionary.count } }
    
    // keys isn't lazy evaluated because it's just an array anyway
    //var keys: [KeyType] { get { return keys } }
    
    // values is lazy evaluated because of the dictionary lookup and creating a new array
    var values: AnyIterator<ValueType> {
        get {
            var index = 0
            return AnyIterator<ValueType> {
                if index >= self.keys.count {
                    return nil
                } else {
                    let key = self.keys[index]
                    index += 1
                    return self.dictionary[key]
                }
            }
        }
    }
}

extension OrderedDictionary : Sequence {
    func makeIterator() -> AnyIterator<(KeyType, ValueType)> {
        var index = 0
        return AnyIterator<(KeyType, ValueType)> {
            if index >= self.keys.count {
                return nil
            } else {
                let key = self.keys[index]
                index += 1
                return (key: key, value: self.dictionary[key]!)
            }
        }
    }
}

func ==<Key: Equatable, Value: Equatable>(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>)
    -> Bool {
        return lhs.keys == rhs.keys && lhs.dictionary == rhs.dictionary
}

func !=<Key: Equatable, Value: Equatable>(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>)
    -> Bool {
        return lhs.keys != rhs.keys || lhs.dictionary != rhs.dictionary
}

extension Dictionary {
    init(_ array: [(Key, Value)]) {
        var result: [Key: Value] = [:]
        for (key, value) in array {
            result[key] = value
        }
        self = result
    }
}
