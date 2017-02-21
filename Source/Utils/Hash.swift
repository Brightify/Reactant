//
//  Hash.swift
//  Reactant
//
//  Created by Filip Dolnik on 10.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

private let djbHashInitialValue = 5381

private func computeDjbHash(accumulator: Int, hashValue: Int) -> Int {
    return (accumulator << 5) &+ accumulator &+ hashValue
}

extension Sequence where Iterator.Element == Int {
    
    public func djbHash() -> Int {
        return reduce(djbHashInitialValue, computeDjbHash)
    }
}

extension Sequence where Iterator.Element == Int? {
    
    public func djbHash() -> Int {
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
    
    public func djbHash() -> Int {
        return reduce(djbHashInitialValue) {
            computeDjbHash(accumulator: $0, hashValue: $1.hashValue)
        }
    }
}

