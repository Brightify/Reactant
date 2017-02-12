//
//  TODO.swift
//  Reactant
//
//  Created by Filip Dolnik on 10.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation


extension Collection {
    func groupBy<KEY: Hashable>(_ extractKey: (Iterator.Element) -> KEY) -> [(KEY, [Iterator.Element])] {
        return groupBy { Optional(extractKey($0)) }
    }
    
    func groupBy<KEY: Hashable>(_ extractKey: (Iterator.Element) -> KEY?) -> [(KEY, [Iterator.Element])] {
        var grouped: [(KEY, [Iterator.Element])] = []
        var t: [String] = []
        func add(_ item: Iterator.Element, forKey key: KEY) {
            if let index = grouped.index(where: { $0.0 == key }) {
                let value = grouped[index]
                grouped[index] = (key, value.1.arrayByAppending(item))
            } else {
                grouped.append((key, [item]))
            }
        }
        
        for item in self {
            guard let key = extractKey(item) else {
                continue
            }
            add(item, forKey: key)
        }
        return grouped
    }
}

extension Dictionary {
    init(keyValueTuples: [(Key, Value)]) {
        var result: [Key: Value] = [:]
        for item in keyValueTuples {
            result[item.0] = item.1
        }
        self = result
    }
}

extension Sequence where Iterator.Element: Equatable {
    func distinct() -> [Iterator.Element] {
        var result: [Iterator.Element] = []
        for item in self where result.contains(item) == false {
            result.append(item)
        }
        return result
    }
}

extension Sequence {
    func distinct(where comparator: (_ lhs: Iterator.Element, _ rhs: Iterator.Element) -> Bool) -> [Iterator.Element] {
        var result: [Iterator.Element] = []
        for item in self where result.contains(where: { comparator(item, $0) }) == false {
            result.append(item)
        }
        return result
    }
}

private let djbHashInitialValue = 5381
private func computeDjbHash(accumulator: Int, hashValue: Int) -> Int {
    return (accumulator << 5) &+ accumulator &+ hashValue
}

extension Sequence where Iterator.Element == Int {
    func djbHash() -> Int {
        return reduce(djbHashInitialValue, computeDjbHash)
    }
}

extension Sequence where Iterator.Element == Int? {
    func djbHash() -> Int {
        return reduce(djbHashInitialValue) {
            if let hashValue = $1 {
                return computeDjbHash(accumulator: $0, hashValue: hashValue)
            } else {
                return $0
            }
        }
    }
}

extension Sequence where Iterator.Element: Hashable {
    func djbHash() -> Int {
        return reduce(djbHashInitialValue) {
            computeDjbHash(accumulator: $0, hashValue: $1.hashValue)
        }
    }
}


import UIKit


extension UIImage {
    var aspectRatio: CGFloat {
        return size.width / size.height
    }
}


extension Sequence {
    func take(until: (Iterator.Element) -> Bool) -> [Iterator.Element] {
        var result: [Iterator.Element] = []
        for item in self {
            guard until(item) else { break }
            result.append(item)
        }
        return result
    }
}


extension RangeReplaceableCollection {
    mutating func remove(until: (Iterator.Element) -> Bool) -> [Iterator.Element] {
        let result = take(until: until)
        removeFirst(result.count)
        return result
    }
}

extension Sequence {
    
    func first(where condition: (Iterator.Element) -> Bool) -> Iterator.Element? {
        for item in self where condition(item) {
            return item
        }
        return nil
    }
    
    func all(predicate: (Iterator.Element) -> Bool) -> Bool {
        for element in self where !predicate(element) {
            return false
        }
        return true
    }
    
    func any(predicate: (Iterator.Element) -> Bool) -> Bool {
        return first(where: predicate) != nil
    }
}
