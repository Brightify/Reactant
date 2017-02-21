//
//  RangeReplaceableCollection+Utils.swift
//  Reactant
//
//  Created by Filip Dolnik on 21.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

extension RangeReplaceableCollection {
    
    public mutating func remove(until: (Iterator.Element) -> Bool) -> [Iterator.Element] {
        let result = take(until: until)
        removeFirst(result.count)
        return result
    }
}
