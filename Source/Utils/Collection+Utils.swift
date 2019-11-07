//
//  Collection+Utils.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

extension Collection {
    
    public func groupBy<KEY: Hashable>(_ extractKey: (Iterator.Element) -> KEY) -> [(KEY, [Iterator.Element])] {
        return groupBy { Optional(extractKey($0)) }
    }
    
    public func groupBy<KEY: Hashable>(_ extractKey: (Iterator.Element) -> KEY?) -> [(KEY, [Iterator.Element])] {
        var grouped: [(KEY, [Iterator.Element])] = []
        var t: [String] = []
        func add(_ item: Iterator.Element, forKey key: KEY) {
            if let index = grouped.firstIndex(where: { $0.0 == key }) {
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

